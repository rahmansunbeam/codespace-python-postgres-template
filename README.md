# devcontainer-python-pgsql-rust
A repo to create a devcontainer with python, postgresql, rust and jupyterlab. This can also be used in Codespace.

### Steps to setup
- install docker and vscode
- clone this repo to the work folder
- open the folder inside vscode
- `ctrl+Shift+p` inside vsdode and choose to open inside container
- done !

### Connecting PostgreSQL with Django
https://stackpython.medium.com/how-to-start-django-project-with-a-database-postgresql-aaa1d74659d8

### added GPU capability to the container
- installed NVIDIA driver (v545.0) and CUDA 12.0 to the host machine
- installed Nvidia Container Toolkit and finally `nvidia-docker2` to the host

### connect to Postgresql from bash (`psql -h <host> -p <port> -U pguser <database>`)
`sudo service postgresql start`
`psql -h localhost -p 5432 -U pguser pgdb`