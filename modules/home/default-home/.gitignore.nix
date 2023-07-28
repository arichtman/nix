[
  # Created by https://www.toptal.com/developers/gitignore/api/hugo,rust,linux,macos,direnv,python,windows,terraform,terragrunt,rust-analyzer,dotnetcore
  # Edit at https://www.toptal.com/developers/gitignore?templates=hugo,rust,linux,macos,direnv,python,windows,terraform,terragrunt,rust-analyzer,dotnetcore

  ### direnv ###
  ".direnv"

  ### DotnetCore ###
  # .NET Core build folders
  "bin/"
  "obj/"

  # Common node modules locations
  "/node_modules"
  "/wwwroot/node_modules"

  ### Hugo ###
  # Generated files by hugo
  "/public/"
  "/resources/_gen/"
  "/assets/jsconfig.json"
  "hugo_stats.json"

  # Executable may be added to repository
  "hugo.exe"
  "hugo.darwin"
  "hugo.linux"

  # Temporary lock file while building
  "/.hugo_build.lock"

  ### Linux ###
  "*~"

  # temporary files which can be created if a process still has a handle open of a deleted file
  ".fuse_hidden*"

  # KDE directory preferences
  ".directory"

  # Linux trash folder which might appear on any partition or disk
  ".Trash-*"

  # .nfs files are created when an open file is removed but is still being accessed
  ".nfs*"

  ### macOS ###
  # General
  ".DS_Store"
  ".AppleDouble"
  ".LSOverride"

  # Icon must end with two \r
  "Icon"

  # Thumbnails
  "._*"

  # Files that might appear in the root of a volume
  ".DocumentRevisions-V100"
  ".fseventsd"
  ".Spotlight-V100"
  ".TemporaryItems"
  ".Trashes"
  ".VolumeIcon.icns"
  ".com.apple.timemachine.donotpresent"

  # Directories potentially created on remote AFP share
  ".AppleDB"
  ".AppleDesktop"
  "Network Trash Folder"
  "Temporary Items"
  ".apdisk"

  ### macOS Patch ###
  # iCloud generated files
  "*.icloud"

  ### Python ###
  # Byte-compiled / optimized / DLL files
  "__pycache__/"
  "*.py[cod]"
  "*$py.class"

  # C extensions
  "*.so"

  # Distribution / packaging
  ".Python"
  "build/"
  "develop-eggs/"
  "dist/"
  "downloads/"
  "eggs/"
  ".eggs/"
  "lib/"
  "lib64/"
  "parts/"
  "sdist/"
  "var/"
  "wheels/"
  "share/python-wheels/"
  "*.egg-info/"
  ".installed.cfg"
  "*.egg"
  "MANIFEST"

  # PyInstaller
  #  Usually these files are written by a python script from a template
  #  before PyInstaller builds the exe, so as to inject date/other infos into it.
  "*.manifest"
  "*.spec"

  # Installer logs
  "pip-log.txt"
  "pip-delete-this-directory.txt"

  # Unit test / coverage reports
  "htmlcov/"
  ".tox/"
  ".nox/"
  ".coverage"
  ".coverage.*"
  ".cache"
  "nosetests.xml"
  "coverage.xml"
  "*.cover"
  "*.py,cover"
  ".hypothesis/"
  ".pytest_cache/"
  "cover/"

  # Translations
  "*.mo"
  "*.pot"

  # Django stuff:
  "*.log"
  "local_settings.py"
  "db.sqlite3"
  "db.sqlite3-journal"

  # Flask stuff:
  "instance/"
  ".webassets-cache"

  # Scrapy stuff:
  ".scrapy"

  # Sphinx documentation
  "docs/_build/"

  # PyBuilder
  ".pybuilder/"
  "target/"

  # Jupyter Notebook
  ".ipynb_checkpoints"

  # IPython
  "profile_default/"
  "ipython_config.py"

  # pyenv
  #   For a library or package, you might want to ignore these files since the code is
  #   intended to run in multiple environments; otherwise, check them in:
  # .python-version

  # pipenv
  #   According to pypa/pipenv#598, it is recommended to include Pipfile.lock in version control.
  #   However, in case of collaboration, if having platform-specific dependencies or dependencies
  #   having no cross-platform support, pipenv may install dependencies that don't work, or not
  #   install all needed dependencies.
  #Pipfile.lock

  # poetry
  #   Similar to Pipfile.lock, it is generally recommended to include poetry.lock in version control.
  #   This is especially recommended for binary packages to ensure reproducibility, and is more
  #   commonly ignored for libraries.
  #   https://python-poetry.org/docs/basic-usage/#commit-your-poetrylock-file-to-version-control
  #poetry.lock

  # pdm
  #   Similar to Pipfile.lock, it is generally recommended to include pdm.lock in version control.
  #pdm.lock
  #   pdm stores project-wide configurations in .pdm.toml, but it is recommended to not include it
  #   in version control.
  #   https://pdm.fming.dev/#use-with-ide
  ".pdm.toml"

  # PEP 582; used by e.g. github.com/David-OConnor/pyflow and github.com/pdm-project/pdm
  "__pypackages__/"

  # Celery stuff
  "celerybeat-schedule"
  "celerybeat.pid"

  # SageMath parsed files
  "*.sage.py"

  # Environments
  ".env"
  ".venv"
  "env/"
  "venv/"
  "ENV/"
  "env.bak/"
  "venv.bak/"

  # Spyder project settings
  ".spyderproject"
  ".spyproject"

  # Rope project settings
  ".ropeproject"

  # mkdocs documentation
  "/site"

  # mypy
  ".mypy_cache/"
  ".dmypy.json"
  "dmypy.json"

  # Pyre type checker
  ".pyre/"

  # pytype static type analyzer
  ".pytype/"

  # Cython debug symbols
  "cython_debug/"

  # PyCharm
  #  JetBrains specific template is maintained in a separate JetBrains.gitignore that can
  #  be found at https://github.com/github/gitignore/blob/main/Global/JetBrains.gitignore
  #  and can be added to the global gitignore or merged into this file.  For a more nuclear
  #  option (not recommended) you can uncomment the following to ignore the entire idea folder.
  #.idea/

  ### Python Patch ###
  # Poetry local configuration file - https://python-poetry.org/docs/configuration/#local-configuration
  "poetry.toml"

  # ruff
  ".ruff_cache/"

  # LSP config files
  "pyrightconfig.json"

  ### Rust ###
  # Generated by Cargo
  # will have compiled files and executables
  "debug/"

  # Remove Cargo.lock from gitignore if creating an executable, leave it for libraries
  # More information here https://doc.rust-lang.org/cargo/guide/cargo-toml-vs-cargo-lock.html
  "Cargo.lock"

  # These are backup files generated by rustfmt
  "**/*.rs.bk"

  # MSVC Windows builds of rustc generate these, which store debugging information
  "*.pdb"

  ### rust-analyzer ###
  # Can be generated by other build systems other than cargo (ex: bazelbuild/rust_rules)
  "rust-project.json"

  ### Terraform ###
  # Local .terraform directories
  "**/.terraform/*"

  # .tfstate files
  "*.tfstate"
  "*.tfstate.*"

  # Crash log files
  "crash.log"
  "crash.*.log"

  # Exclude all .tfvars files, which are likely to contain sensitive data, such as
  # password, private keys, and other secrets. These should not be part of version
  # control as they are data points which are potentially sensitive and subject
  # to change depending on the environment.
  "*.tfvars"
  "*.tfvars.json"

  # Ignore override files as they are usually used to override resources locally and so
  # are not checked in
  "override.tf"
  "override.tf.json"
  "*_override.tf"
  "*_override.tf.json"

  # Include override files you do wish to add to version control using negated pattern
  # !example_override.tf

  # Include tfplan files to ignore the plan output of command: terraform plan -out=tfplan
  # example: *tfplan*

  # Ignore CLI configuration files
  ".terraformrc"
  "terraform.rc"

  ### Terragrunt ###
  # terragrunt cache directories
  "**/.terragrunt-cache/*"

  # Terragrunt debug output file (when using `--terragrunt-debug` option)
  # See: https://terragrunt.gruntwork.io/docs/reference/cli-options/#terragrunt-debug
  "terragrunt-debug.tfvars.json"

  ### Windows ###
  # Windows thumbnail cache files
  "Thumbs.db"
  "Thumbs.db:encryptable"
  "ehthumbs.db"
  "ehthumbs_vista.db"

  # Dump file
  "*.stackdump"

  # Folder config file
  "[Dd]esktop.ini"

  # Recycle Bin used on file shares
  "$RECYCLE.BIN/"

  # Windows Installer files
  "*.cab"
  "*.msi"
  "*.msix"
  "*.msm"
  "*.msp"

  # Windows shortcuts
  "*.lnk"

  # End of https://www.toptal.com/developers/gitignore/api/hugo,rust,linux,macos,direnv,python,windows,terraform,terragrunt,rust-analyzer,dotnetcore
]
