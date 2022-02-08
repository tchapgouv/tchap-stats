const cron = require("cron")

const job =
  {
    cronTime: "* * * * *", // every minute
    onTick: fetchFromS3,
    start: true,
    timeZone: "Europe/Paris",
    isActive: true,
    name: "Fetch from s3",
  }

if (job.isActive) {
  console.log(`🚀 The job "${job.name}" is ON`)
  new cron.CronJob(job)
  console.log(`Started job ${job.name}`)
} else {
  console.log(`❌ The job "${job.name}" is OFF`)
}

const fetchFromS3 = () => {
  console.log("Coucou !!!!!")
}