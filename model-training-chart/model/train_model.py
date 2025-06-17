import os
import json
import pandas as pd
from sqlalchemy import create_engine
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, udf
from pyspark.ml.linalg import Vectors, VectorUDT

from logger import AppLogger
from clustering_model import ClusteringModel

def read_from_postgres():
    db_config = {
        "dbname": os.environ["DB_NAME"],
        "user": os.environ["DB_USER"],
        "password": os.environ["password"],
        "host": os.environ["DB_HOST"],
        "port": os.environ["DB_PORT"]
    }
    
    engine = create_engine(
        f"postgresql+psycopg2://{db_config['user']}:{db_config['password']}"
        f"@{db_config['host']}:{db_config['port']}/{db_config['dbname']}"
    )
    
    query = "SELECT * FROM processed_data"
    return pd.read_sql(query, engine)

def main():
    # 从环境变量获取路径
    spark_events_path = os.environ.get("SPARK_EVENTS_DIR", "/data/spark-events")
    model_path = os.environ.get("MODEL_SAVE_PATH", "/data/model")
    log_path = os.environ.get("LOG_PATH", "/data/app.log")
    
    os.makedirs(os.path.dirname(spark_events_path), exist_ok=True)
    os.makedirs(os.path.dirname(model_path), exist_ok=True)
    
    logger = AppLogger(log_file=log_path).get_logger()
    logger.info("Application started")
    
    try:
        # 加载 Spark 配置
        spark_config = json.loads(os.environ["SPARK_CONFIG"])
        
        spark = SparkSession.builder \
            .appName("ModelTraining") \
            .config("spark.driver.memory", spark_config["driver_memory"]) \
            .config("spark.executor.memory", spark_config["executor_memory"]) \
            .config("spark.executor.cores", str(spark_config["executor_cores"])) \
            .config("spark.sql.shuffle.partitions", str(spark_config["shuffle_partitions"])) \
            .config("spark.sql.execution.arrow.pyspark.enabled", "true") \
            .config("spark.dynamicAllocation.enabled", "false") \
            .config("spark.eventLog.enabled", "true") \
            .config("spark.eventLog.dir", spark_events_path) \
            .getOrCreate()
        
        logger.info("Spark session created")
        logger.info(f"Reading data from DB: {os.environ['DB_HOST']}")
        
        df_pd = read_from_postgres()
        df = spark.createDataFrame(df_pd)
        
        str_to_vector_udf = udf(
            lambda s: Vectors.dense([float(x) for x in s.split(',')]) if s else None,
            VectorUDT()
        )
        df = df.withColumn("scaled_features", str_to_vector_udf(col("scaled_features_str")))
        df = df.select("scaled_features")
        
        logger.info("Starting model training")
        model = ClusteringModel(k=int(os.environ.get("K_CLUSTERS", 3)), seed=42)
        model.train(df)
        predictions = model.model.transform(df)
        logger.info(f"Inertia: {model.model.summary.trainingCost:.2f}")
        
        model.save(model_path, overwrite=True)
        logger.info(f"Model saved to {model_path}")
        
    except Exception as e:
        logger.error(f"Application failed: {str(e)}", exc_info=True)
        raise
    finally:
        if 'spark' in locals():
            spark.stop()
            logger.info("Spark session stopped")

if __name__ == "__main__":
    main()