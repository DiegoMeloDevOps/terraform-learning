data "aws_ami" "ubuntu" {

  # versão mais recente
  most_recent = true
  # do proprietario oficial da imagem q
  owners = ["099720109477"]


  # filtro para achar uma versão especifica do ubuntu
  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    ]
  }
  # uma maquina que seu tipo de virtualização seja hvm
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}


resource "aws_instance" "web" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

}