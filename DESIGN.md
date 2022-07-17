# Jahbs

Jahbs is a minimal golang CLI, and API Server that can execute
arbitrary unix jobs. It is similar to docker in nature.

## API

The client-server api is defined in GRPC and offers for endpoints:

* Start - Start a new job
* Stop - Stop a currently running job
* GetStatus - Get the status or exit code of a job.
* GetLogs - Stream the standard out and standard error output of a job.

For more information, see the included [protobuf definition](api.proto)

## Client

The client provides a command line `jbs` command that can perform each of the
above API calls. Here is example usage:

### Start
```shell
$ jbs start -- top -b -n 10
Started: 57d17d04-0480-11ed-b939-0242ac120002
```

All parameters to after `--` are treated as the command to be run.
This allows flexibility for addition of future `jbs` flags

To limit scope, `jbs` does not allow setting custom environment variables.

### Stop
```shell
$ jbs stop 57d17d04-0480-11ed-b939-0242ac120002
```

### Status
`jbs status` may be called while a job is running or after it completes:

```shell
$ jbs status 57d17d04-0480-11ed-b939-0242ac120002
57d17d04-0480-11ed-b939-0242ac120002 is running
```

If the job is complete (say it was stopped) the exit code is shown:

```shell
$ jbs status 57d17d04-0480-11ed-b939-0242ac120002
57d17d04-0480-11ed-b939-0242ac120002 exited with code 137
```

## Logs
```shell
$ jbs logs 57d17d04-0480-11ed-b939-0242ac120002
top - 17:37:11 up 10 days,  7:29, 19 users,  load average: 0.20, 0.47, 0.66
Tasks: 444 total,   1 running, 443 sleeping,   0 stopped,   0 zombie
...
```

Standard out and standard error are printed to their respective local
filehandles.

## Other client concerns
The client connects to a default endpoint of http://localhost:80. This can
be configured with the following environment variable:
```
export JBS_ENDPOINT=http://127.0.0.1:8080
```

## Server

The `jahbs` server receives gRPC calls from the client on port 80 and executes
the work.

UUIDs are generated using https://github.com/google/uuid

```go
type Job struct{
    UUID uuid.UUID
    Cmd  exec.Cmd
    // figure out stdout/stderr buffer
}

type JobMap struct{
    lock sync.RWMutex
    jobs map[uuid.UUID][Job]
}

func (m *JobMap) get(k uuid.UUID) (Job, error) {...}

func (m *JobMap) put(k uuid.UUID, j Job) {...}
```

TODO:
* in memory interlaced stderr/stdout format, needs to support multiple readers
* max buffer size - provide a sane default and override
* when max is hit, use a ringbuffer such that oldest content is overwritten first?

The following are ignored to keep scope minimal:
* limiting the stdout / stderr buffers
* establishing a max job retention and releasing old jobs
* persisting the job map and job output beyond the server lifecycle
