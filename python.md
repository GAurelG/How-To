# Use Virtual environment:

This is a test, complete when more used

## To create a virtual environment:

### create a directory:

For my own organization I would create the directory in `/home/aurelien/Python/Virtualenv/VIRTUALENV_FOLDER/` (actually changed but get the idea)

if using with git, can create a higher level directory to hold the virtualenvironment subdirectory and the scripts in the higher level

### create a virutal environment:

1. Python 2:
    + need the module `virtualenv`
    + then on the directory already created: `virtualenv DIRECTORY_NAME`
2. Python 3:
    + already in the python standard library
    + but need to install python3-venv on ubuntu 18.04
    + `python3 -m venv DIRECTORY_NAME`

### Working in a Virtual environment:

- **Activate** the environment:
    
    `source DIRECTORY_NAME/bin/activate` 

    On windows use the `bin\activate.bat` and for other shell look at `bin/` content in the directory.

    Now we are working in the virtual environment 

- **Exit** the virtual environment:
    
    `deactivate`
### installing packages in the environment:

Once the virtual environment has been created, activate it. then run your normal: `pip install PACKAGE`
You should be able to see the packages in the virtualenvironment/lib/python3.X/site-packages/ .
Another usefull thing is the possibility to use a text file with pip to install several packages at once.

To create the file, redirect the output of `pip freeze` into a file, I will name it "requirements.txt" but it could be anything.
The command is: `pip freeze > requirements.txt` 

then in the new virtual environment run `pip install -r requirements.txt`

### Loading modules:

***To-Do***

### Increase Productivity Idea?

- make alias to {source virtualenv}? for trivial virtualenv? (ipython...)
