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