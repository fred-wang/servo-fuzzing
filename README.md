# Servo fuzzing

These are simple helper scripts to exercize Servo on public fuzzers, minimize
testcases and report issues (no automated infrastructure). The only fuzzer
category tried so far is the one of DOM fuzzers like Domato and the only issues
looked for are panic messages. Nothing really fancy here but hopefully useful
for Servo developers!

## Generating test cases

### [Domato](https://github.com/googleprojectzero/domato)

```
git clone git@github.com:googleprojectzero/domato.git
python domato/generator.py -o testcases/ -n 100
```

### [Freedom](https://github.com/sslab-gatech/freedom)

```
git clone git@github.com:sslab-gatech/freedom.git
python freedom/main.py -i 1 -m generate -n 100 -o testcases
```

### [Minerva](https://github.com/ChijinZ/Minerva)

```
git clone git@github.com:ChijinZ/Minerva.git
export MEM_DEP_JSON_PATH=Minerva/mod_ref_helper/mem_dep.json
python Minerva/generator.py --output_dir testcases --no_of_files 100
```

## Running test cases in Servo

If you don't have a local build of Servo, you can use
`download-latest-nightly.sh` to retrieve the latest Linux nightly build.

To run all the HTML files with Servo in headless mode and generate corresponding
`.txt` output:

```
./run-testcases.sh testcases/ ./path/to/servoshell [servo_extra_args]
```

`--enable-experimental-web-platform-features` can be an interesting argument to
pass if you want to test fuzz experimental web platform features.

The bash script will run `print-unknown-panic.sh` at the end, which filters out
known panic messages from `.txt` output. Please keep this file updated.

## Reducing test cases

You can use [Lithium](https://github.com/MozillaSecurity/lithium/) to reduce a testcase, for example

```
python3 -m lithium crashes -t1 ./path/to/servoshell -xzf testcase.html
```

or to narrow down a specific panic message:

```
python3 -m lithium outputs -t1 -s 'my panic message' ./path/to/servoshell -xzf testcase.html
```

There are also scripts to help reduce non-deterministic testcase more quickly:

```
python3 -m lithium outputs -t3 -s 'my panic message' ./repeat.sh ./path/to/servoshell -xzf testcase.html
```

```
python3 -m lithium outputs -t3 -s 'my panic message' ./parallelize.sh ./path/to/servoshell -xzf testcase.html
```

There are other Lithium options and semi-automated reduction tricks you can
apply to get a smaller/cleaner repro, but the above commands should generally
be good enough.

## Reporting issues

To generate a draft for the [GitHub issue tracker](https://github.com/servo/servo/issues), use the following command:

```
./print-github-report.sh minimized-testcase.html ./path/to/servoshell [servo_args]
```

Note that contrary to `./run-testcases.sh`, this does not pass the `--headless`
argument by default. Please specify it explicitly if it is needed to reproduce
the crash.

## Reproducing previously-reported issues

Copy the reported testcase in a `testcase.html` file and run the following
command:

```
./path/to/servoshell -xf testcase.html
```

The report may indicate extra command line parameters to provide, such as
`--enable-experimental-web-platform-features` or`-z`/`--headless`.

For flaky test cases, you can use `repeat.sh` or `parallelize.sh` scripts
to repeat executions in order to reproduce more easily, for instance:

```
./repeat.sh ./path/to/servoshell -xzf testcase.html # repeat 10 times.
./parellize.sh ./path/to/servoshell -xzf testcase.html # execute 10 times in parallel.
./repeat.sh ./parellize.sh ./path/to/servoshell -xf testcase.html # repeat 10 times the 10 parallel executions.
```

By default these scripts use a `COUNT` of 10, feel free to increase it if
necessary.

Finally `reproduce.sh` is a handy script that performs 10 repetitions of 100
parallel executions and calculates a reproducibility estimate. Its first
argument is the regexp passed to `egrep` when the output is tested. For example
for [issue #36850](https://github.com/servo/servo/issues/36850) we get
something like this:

```
./reproduce.sh "Cache should have been filled from traversal" ./path/to/servoshell -xzf testcase.html
1/10: running  instances in parallel...
2/10: running  instances in parallel...
3/10: running  instances in parallel...
4/10: running  instances in parallel...
5/10: running  instances in parallel...
6/10: running  instances in parallel...
7/10: running  instances in parallel...
8/10: running  instances in parallel...
9/10: running  instances in parallel...
10/10: running  instances in parallel...
Reproducibility: 15%
```
