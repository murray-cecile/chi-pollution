import org.apache.spark.sql.SaveMode


val noise_sum = spark.sql(
    """
    select node_id,
    sum(value_hrf) as db_sum,
    count(value_hrf) as db_ct,
    max(value_hrf) as db_max
    from cmmurray_sensor_csv
    where sensor = "spv1840lr5h_b" and
    value_hrf IS NOT NULL
    group by node_id
    """
)

noise_sum.write.mode(SaveMode.Overwrite).saveAsTable("cmmurray_noise_sum")

val max_noise = spark.sql(
    """
    SELECT node_id, 
    MAX(value_hrf) as db_max
    FROM cmmurray_sensor_csv
    WHERE sensor = "spv1840lr5h_b" AND value_hrf IS NOT NULL
    GROUP BY node_id
    """
)

max_noise.write.mode(SaveMode.Overwrite).saveAsTable("cmmurray_max_noise")


val daily_noise = spark.sql(
    """
    SELECT node_id,
    SUM(db_sum) as db_sum,
    SUM(db_ct) as db_ct,
    COUNT(day) as day_ct
    FROM cmmurray_noise_sum
    WHERE db_sum IS NOT NULL
    GROUP BY node_id
    """
)

daily_noise.write.mode(SaveMode.Overwrite).saveAsTable("cmmurray_daily_noise")