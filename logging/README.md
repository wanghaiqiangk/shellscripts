# Logging

A simple shell logging facility that offers basic requirements like different level selection/suspending, output to console/file.

## Shell Requirements

The syntax tries to be legal and common both to Bourne Shell and Bourne Again Shell. For any other shells, I can not promise it works.

## Log Message Format

```shell
[year-month-day hour:minute:second] [pid] [level-id] : [log-message]
```

- The date format is conformed to `date` or `strftime`
- If the log message is printed to standard output, the level-id is colorized based on severity, from white to red

| Severity | Color  | Intrinsic Integer Value | Constant Variable |
| -------- | ------ | ----------------------- | ----------------- |
| DEBUG    | White  | 0                       | LVL_DEBUG         |
| INFO     | Green  | 1                       | LVL_INFO          |
| WARN     | Yellow | 2                       | LVL_WARN          |
| FATAL    | Red    | 3                       | LVL_FATAL         |

*Note* The message of fatal level is also colorized as the same of level-id, in order to make it more recognizable.

## Usage

First of all, source the script.

```shell
source /path/to/shell_logging.sh
```

Then simply log anything that you want.

```shell
DEBUG This is debug message
INFO This is info message
WARN This is warn message
FATAL This is fatal message
```

### Change Default Severity

The default severity is INFO. To change that, one can call `LOG_LEVEL` with the integer value to the desired level.

```shell
LOG_LEVEL $LVL_DEBUG
LOG_LEVEL $LVL_WARN
```

### Change Logging to File

Call `LOG_WHERE` with a string of path to the file. If there is already an existing file, that file will be truncated first and then be used to write log.

```shell
LOG_WHERE "./shell.log"
```

