# Batch processing engines:
    
    - apache HADOOP
    - apache Spark

good = robust and deliver good results on historical and batch data
bad = can't process "real time" event or streams of event.

# Streaming engine:

    - apache Storm
    - apache Samza

good = can process real time streams of data
bad = can deliver inacurate result if some event didn't arrive or aren't processed. Can't process historical data

# Combining stream and batch engine:

    - apache flink
good = runs on different data storage and ressource management tools (k8s, mesos, Yarn...) and provides both stream and batch capability depending on the type of stream
