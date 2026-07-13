import logging

logging.basicConfig(
    level=logging.INFO
)

logger = logging.getLogger("worker")


logger.info("Worker started")

logger.info(
    f"Processing job {body['jobId']}"
)
