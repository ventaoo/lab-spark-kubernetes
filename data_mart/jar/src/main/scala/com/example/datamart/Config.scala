package com.example.datamart

case class Config(
  inputPath: String,
  sparkMaster: String,
  dbUrl: String,
  dbUser: String,
  dbPassword: String
)