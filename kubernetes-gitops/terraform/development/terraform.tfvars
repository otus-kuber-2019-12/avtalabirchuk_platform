project = "terraform-instance"
credentials_file = "my-firstproject-terraform-214691cfe6b5.json"

region = "us-central1"

machine_types = {
  dev  = "f1-micro"
  test = "n1-highcpu-32"
  prod = "n1-highcpu-32"
}