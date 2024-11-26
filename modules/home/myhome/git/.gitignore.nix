[
  "result"
  # Created by https://www.toptal.com/developers/gitignore/api/hugo,rust,linux,macos,csharp,direnv,python,windows,terraform,dotnetcore,terragrunt,rust-analyzer,node,yarn
  # Edit at https://www.toptal.com/developers/gitignore?templates=hugo,rust,linux,macos,csharp,direnv,python,windows,terraform,dotnetcore,terragrunt,rust-analyzer,node,yarn

  ### Csharp ###
  ## Ignore Visual Studio temporary files, build results, and
  ## files generated by popular Visual Studio add-ons.
  ##
  ## Get latest from https://github.com/github/gitignore/blob/main/VisualStudio.gitignore

  # User-specific files
  "*.rsuser"
  "*.suo"
  "*.user"
  "*.userosscache"
  "*.sln.docstates"

  # User-specific files (MonoDevelop/Xamarin Studio)
  "*.userprefs"

  # Mono auto generated files
  "mono_crash.*"

  # Build results
  "[Dd]ebug/"
  "[Dd]ebugPublic/"
  "[Rr]elease/"
  "[Rr]eleases/"
  "x64/"
  "x86/"
  "[Ww][Ii][Nn]32/"
  "[Aa][Rr][Mm]/"
  "[Aa][Rr][Mm]64/"
  "bld/"
  "[Bb]in/"
  "[Oo]bj/"
  "[Ll]og/"
  "[Ll]ogs/"

  # Visual Studio 2015/2017 cache/options directory
  ".vs/"
  # Uncomment if you have tasks that create the project's static files in wwwroot
  #wwwroot/

  # Visual Studio 2017 auto generated files
  "Generated\ Files/"

  # MSTest test Results
  "[Tt]est[Rr]esult*/"
  "[Bb]uild[Ll]og.*"

  # NUnit
  "*.VisualState.xml"
  "TestResult.xml"
  "nunit-*.xml"

  # Build Results of an ATL Project
  "[Dd]ebugPS/"
  "[Rr]eleasePS/"
  "dlldata.c"

  # Benchmark Results
  "BenchmarkDotNet.Artifacts/"

  # .NET Core
  "project.lock.json"
  "project.fragment.lock.json"
  "artifacts/"

  # ASP.NET Scaffolding
  "ScaffoldingReadMe.txt"

  # StyleCop
  "StyleCopReport.xml"

  # Files built by Visual Studio
  "*_i.c"
  "*_p.c"
  "*_h.h"
  "*.ilk"
  "*.meta"
  "*.obj"
  "*.iobj"
  "*.pch"
  "*.pdb"
  "*.ipdb"
  "*.pgc"
  "*.pgd"
  "*.rsp"
  "*.sbr"
  "*.tlb"
  "*.tli"
  "*.tlh"
  "*.tmp"
  "*.tmp_proj"
  "*_wpftmp.csproj"
  "*.log"
  "*.tlog"
  "*.vspscc"
  "*.vssscc"
  ".builds"
  "*.pidb"
  "*.svclog"
  "*.scc"

  # Chutzpah Test files
  "_Chutzpah*"

  # Visual C++ cache files
  "ipch/"
  "*.aps"
  "*.ncb"
  "*.opendb"
  "*.opensdf"
  "*.sdf"
  "*.cachefile"
  "*.VC.db"
  "*.VC.VC.opendb"

  # Visual Studio profiler
  "*.psess"
  "*.vsp"
  "*.vspx"
  "*.sap"

  # Visual Studio Trace Files
  "*.e2e"

  # TFS 2012 Local Workspace
  "$tf/"

  # Guidance Automation Toolkit
  "*.gpState"

  # ReSharper is a .NET coding add-in
  "_ReSharper*/"
  "*.[Rr]e[Ss]harper"
  "*.DotSettings.user"

  # TeamCity is a build add-in
  "_TeamCity*"

  # DotCover is a Code Coverage Tool
  "*.dotCover"

  # AxoCover is a Code Coverage Tool
  ".axoCover/*"
  "!.axoCover/settings.json"

  # Coverlet is a free, cross platform Code Coverage Tool
  "coverage*.json"
  "coverage*.xml"
  "coverage*.info"

  # Visual Studio code coverage results
  "*.coverage"
  "*.coveragexml"

  # NCrunch
  "_NCrunch_*"
  ".*crunch*.local.xml"
  "nCrunchTemp_*"

  # MightyMoose
  "*.mm.*"
  "AutoTest.Net/"

  # Web workbench (sass)
  ".sass-cache/"

  # Installshield output folder
  "[Ee]xpress/"

  # DocProject is a documentation generator add-in
  "DocProject/buildhelp/"
  "DocProject/Help/*.HxT"
  "DocProject/Help/*.HxC"
  "DocProject/Help/*.hhc"
  "DocProject/Help/*.hhk"
  "DocProject/Help/*.hhp"
  "DocProject/Help/Html2"
  "DocProject/Help/html"

  # Click-Once directory
  "publish/"

  # Publish Web Output
  "*.[Pp]ublish.xml"
  "*.azurePubxml"
  # Note: Comment the next line if you want to checkin your web deploy settings,
  # but database connection strings (with potential passwords) will be unencrypted
  "*.pubxml"
  "*.publishproj"

  # Microsoft Azure Web App publish settings. Comment the next line if you want to
  # checkin your Azure Web App publish settings, but sensitive information contained
  # in these scripts will be unencrypted
  "PublishScripts/"

  # NuGet Packages
  "*.nupkg"
  # NuGet Symbol Packages
  "*.snupkg"
  # The packages folder can be ignored because of Package Restore
  "**/[Pp]ackages/*"
  # except build/, which is used as an MSBuild target.
  "!**/[Pp]ackages/build/"
  # Uncomment if necessary however generally it will be regenerated when needed
  #!**/[Pp]ackages/repositories.config
  # NuGet v3's project.json files produces more ignorable files
  "*.nuget.props"
  "*.nuget.targets"

  # Microsoft Azure Build Output
  "csx/"
  "*.build.csdef"

  # Microsoft Azure Emulator
  "ecf/"
  "rcf/"

  # Windows Store app package directories and files
  "AppPackages/"
  "BundleArtifacts/"
  "Package.StoreAssociation.xml"
  "_pkginfo.txt"
  "*.appx"
  "*.appxbundle"
  "*.appxupload"

  # Visual Studio cache files
  # files ending in .cache can be ignored
  "*.[Cc]ache"
  # but keep track of directories ending in .cache
  "!?*.[Cc]ache/"

  # Others
  "ClientBin/"
  "~$*"
  "*~"
  "*.dbmdl"
  "*.dbproj.schemaview"
  "*.jfm"
  "*.pfx"
  "*.publishsettings"
  "orleans.codegen.cs"

  # Including strong name files can present a security risk
  # (https://github.com/github/gitignore/pull/2483#issue-259490424)
  #*.snk

  # Since there are multiple workflows, uncomment next line to ignore bower_components
  # (https://github.com/github/gitignore/pull/1529#issuecomment-104372622)
  #bower_components/

  # RIA/Silverlight projects
  "Generated_Code/"

  # Backup & report files from converting an old project file
  # to a newer Visual Studio version. Backup files are not needed,
  # because we have git ;-)
  "_UpgradeReport_Files/"
  "Backup*/"
  "UpgradeLog*.XML"
  "UpgradeLog*.htm"
  "ServiceFabricBackup/"
  "*.rptproj.bak"

  # SQL Server files
  "*.mdf"
  "*.ldf"
  "*.ndf"

  # Business Intelligence projects
  "*.rdl.data"
  "*.bim.layout"
  "*.bim_*.settings"
  "*.rptproj.rsuser"
  "*- [Bb]ackup.rdl"
  "*- [Bb]ackup ([0-9]).rdl"
  "*- [Bb]ackup ([0-9][0-9]).rdl"

  # Microsoft Fakes
  "FakesAssemblies/"

  # GhostDoc plugin setting file
  "*.GhostDoc.xml"

  # Node.js Tools for Visual Studio
  ".ntvs_analysis.dat"
  "node_modules/"

  # Visual Studio 6 build log
  "*.plg"

  # Visual Studio 6 workspace options file
  "*.opt"

  # Visual Studio 6 auto-generated workspace file (contains which files were open etc.)
  "*.vbw"

  # Visual Studio 6 auto-generated project file (contains which files were open etc.)
  "*.vbp"

  # Visual Studio 6 workspace and project file (working project files containing files to include in project)
  "*.dsw"
  "*.dsp"

  # Visual Studio 6 technical files

  # Visual Studio LightSwitch build output
  "**/*.HTMLClient/GeneratedArtifacts"
  "**/*.DesktopClient/GeneratedArtifacts"
  "**/*.DesktopClient/ModelManifest.xml"
  "**/*.Server/GeneratedArtifacts"
  "**/*.Server/ModelManifest.xml"
  "_Pvt_Extensions"

  # Paket dependency manager
  ".paket/paket.exe"
  "paket-files/"

  # FAKE - F# Make
  ".fake/"

  # CodeRush personal settings
  ".cr/personal"

  # Python Tools for Visual Studio (PTVS)
  "__pycache__/"
  "*.pyc"

  # Cake - Uncomment if you are using it
  # tools/**
  # !tools/packages.config

  # Tabs Studio
  "*.tss"

  # Telerik's JustMock configuration file
  "*.jmconfig"

  # BizTalk build output
  "*.btp.cs"
  "*.btm.cs"
  "*.odx.cs"
  "*.xsd.cs"

  # OpenCover UI analysis results
  "OpenCover/"

  # Azure Stream Analytics local run output
  "ASALocalRun/"

  # MSBuild Binary and Structured Log
  "*.binlog"

  # NVidia Nsight GPU debugger configuration file
  "*.nvuser"

  # MFractors (Xamarin productivity tool) working folder
  ".mfractor/"

  # Local History for Visual Studio
  ".localhistory/"

  # Visual Studio History (VSHistory) files
  ".vshistory/"

  # BeatPulse healthcheck temp database
  "healthchecksdb"

  # Backup folder for Package Reference Convert tool in Visual Studio 2017
  "MigrationBackup/"

  # Ionide (cross platform F# VS Code tools) working folder
  ".ionide/"

  # Fody - auto-generated XML schema
  "FodyWeavers.xsd"

  # VS Code files for those working on multiple tools
  ".vscode/*"
  "!.vscode/settings.json"
  "!.vscode/tasks.json"
  "!.vscode/launch.json"
  "!.vscode/extensions.json"
  "*.code-workspace"

  # Local History for Visual Studio Code
  ".history/"

  # Windows Installer files from build outputs
  "*.cab"
  "*.msi"
  "*.msix"
  "*.msm"
  "*.msp"

  # JetBrains Rider
  "*.sln.iml"

  ### direnv ###
  ".direnv"
  ".envrc"

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

  ### Node ###
  # Logs
  "logs"
  "npm-debug.log*"
  "yarn-debug.log*"
  "yarn-error.log*"
  "lerna-debug.log*"
  ".pnpm-debug.log*"

  # Diagnostic reports (https://nodejs.org/api/report.html)
  "report.[0-9]*.[0-9]*.[0-9]*.[0-9]*.json"

  # Runtime data
  "pids"
  "*.pid"
  "*.seed"
  "*.pid.lock"

  # Directory for instrumented libs generated by jscoverage/JSCover
  "lib-cov"

  # Coverage directory used by tools like istanbul
  "coverage"
  "*.lcov"

  # nyc test coverage
  ".nyc_output"

  # Grunt intermediate storage (https://gruntjs.com/creating-plugins#storing-task-files)
  ".grunt"

  # Bower dependency directory (https://bower.io/)
  "bower_components"

  # node-waf configuration
  ".lock-wscript"

  # Compiled binary addons (https://nodejs.org/api/addons.html)
  "build/Release"

  # Dependency directories
  "jspm_packages/"

  # Snowpack dependency directory (https://snowpack.dev/)
  "web_modules/"

  # TypeScript cache
  "*.tsbuildinfo"

  # Optional npm cache directory
  ".npm"

  # Optional eslint cache
  ".eslintcache"

  # Optional stylelint cache
  ".stylelintcache"

  # Microbundle cache
  ".rpt2_cache/"
  ".rts2_cache_cjs/"
  ".rts2_cache_es/"
  ".rts2_cache_umd/"

  # Optional REPL history
  ".node_repl_history"

  # Output of 'npm pack'
  "*.tgz"

  # Yarn Integrity file
  ".yarn-integrity"

  # dotenv environment variable files
  ".env"
  ".env.development.local"
  ".env.test.local"
  ".env.production.local"
  ".env.local"

  # parcel-bundler cache (https://parceljs.org/)
  ".cache"
  ".parcel-cache"

  # Next.js build output
  ".next"
  "out"

  # Nuxt.js build / generate output
  ".nuxt"
  "dist"

  # Gatsby files
  ".cache/"
  # Comment in the public line in if your project uses Gatsby and not Next.js
  # https://nextjs.org/blog/next-9-1#public-directory-support
  # public

  # vuepress build output
  ".vuepress/dist"

  # vuepress v2.x temp and cache directory
  ".temp"

  # Docusaurus cache and generated files
  ".docusaurus"

  # Serverless directories
  ".serverless/"

  # FuseBox cache
  ".fusebox/"

  # DynamoDB Local files
  ".dynamodb/"

  # TernJS port file
  ".tern-port"

  # Stores VSCode versions used for testing VSCode extensions
  ".vscode-test"

  # yarn v2
  ".yarn/cache"
  ".yarn/unplugged"
  ".yarn/build-state.yml"
  ".yarn/install-state.gz"
  ".pnp.*"

  ### Node Patch ###
  # Serverless Webpack directories
  ".webpack/"

  # Optional stylelint cache

  # SvelteKit build / generate output
  ".svelte-kit"

  ### Python ###
  # Byte-compiled / optimized / DLL files
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

  # Windows shortcuts
  "*.lnk"

  ### yarn ###
  # https://yarnpkg.com/getting-started/qa#which-files-should-be-gitignored

  ".yarn/*"
  "!.yarn/releases"
  "!.yarn/patches"
  "!.yarn/plugins"
  "!.yarn/sdks"
  "!.yarn/versions"

  # if you are NOT using Zero-installs, then:
  # comment the following lines
  "!.yarn/cache"

  # and uncomment the following lines
  # .pnp.*

  # End of https://www.toptal.com/developers/gitignore/api/hugo,rust,linux,macos,csharp,direnv,python,windows,terraform,dotnetcore,terragrunt,rust-analyzer,node,yarn
]