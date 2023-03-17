jupyter notebook --generate-config
echo "c.NotebookApp.allow_origin = '*'" >> ~/.jupyter/jupyter_notebook_config.py
chown -R $NB_USER:$NB_USER ~/.jupyter
