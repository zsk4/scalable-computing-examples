workon scomp
export JOBNAME=parsl.HighThroughputExecutor.block-2.1744066983.882179
set -e
export CORES=$(getconf _NPROCESSORS_ONLN)
[[ "1" == "1" ]] && echo "Found cores : $CORES"
WORKERCOUNT=1
FAILONANY=0
PIDS=""

CMD() {
process_worker_pool.py  --max_workers_per_node=15 -a 172.17.0.1,128.111.85.28,127.0.0.1,127.0.1.1 -p 0 -c 1.0 -m None --poll 10 --task_port=54254 --result_port=54903 --cert_dir None --logdir=/home/zkatz/scalable-computing-examples/04-pleasing/runinfo/000/HighThroughputExecutor --block_id=2 --hb_period=30  --hb_threshold=120 --drain_period=None --cpu-affinity none  --mpi-launcher=mpiexec --available-accelerators 
}
for COUNT in $(seq 1 1 $WORKERCOUNT); do
    [[ "1" == "1" ]] && echo "Launching worker: $COUNT"
    CMD $COUNT &
    PIDS="$PIDS $!"
done

ALLFAILED=1
ANYFAILED=0
for PID in $PIDS ; do
    wait $PID
    if [ "$?" != "0" ]; then
        ANYFAILED=1
    else
        ALLFAILED=0
    fi
done

[[ "1" == "1" ]] && echo "All workers done"
if [ "$FAILONANY" == "1" ]; then
    exit $ANYFAILED
else
    exit $ALLFAILED
fi
