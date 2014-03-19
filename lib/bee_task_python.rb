# Copyright 2006-2010 Michel Casabianca <michel.casabianca@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'rubygems'
require 'bee_task_package'
require 'fileutils'

module Bee
  
  module Task
  
    # Package for Python tasks.
    class Python < Package
    
      # Compile Python source files, checking syntax and generating .pyc files.
      # Parameter is a glob or list of globs for files to compile.
      # 
      # Example
      # 
      #  - python.compile: "**/*.py"
      def compile(globs)
        error "python.compile parameter is a String or Array of Strings" unless
          globs.kind_of?(String) or globs.kind_of?(Array)
        for glob in globs
          error "python.compile parameter is a String or Array of Strings" unless
            glob.kind_of?(String)
          files = Dir.glob(glob)
          size = (files.kind_of?(Array) ? files.size : 1)
          puts "Compiling #{size} Python source file(s)" if files.length > 0
          script = File.join(File.expand_path(File.dirname(__FILE__)),
                             '..', 'tools', 'compile', 'compile.py')
          for file in files
            puts "Compiling Python source file '#{file}'" if @verbose
            command = "python #{script} #{file}"
            puts "Running command: '#{command}'" if @verbose
            ok = system(command)
            error "Error compiling Python source file '#{file}'" unless ok
          end
        end
      end

      # Run a given Python source file. Parameter is the source file to run
      # (source file must be an existing readable file) or the following ones:
      # 
      # - source: The source file to run.
      # - args: the command line arguments to pass to the scripts.
      # - lenient: If true, will not fail if return value if the process
      #   is different from 0 (which is the default).
      #
      # Example
      #
      #  - python.python: "my_script.py"
      #  - python.python:
      #      source:  "my_script.py"
      #      args:    ["foo", "bar"]
      #      lenient: true
      def python(params)
        lenient = false
        if params.kind_of?(String)
          error "python.python parameter must be an existing file" unless
            File.exists?(params) and File.readable?(params)
          ok = system("python #{params}")
        else
          params_desc = {
            :source =>  { :mandatory => true,  :type => :string },
            :args   =>  { :mandatory => false, :type => :string_or_array },
            :lenient => { :mandatory => false, :type => :boolean,
                          :default   => false }
          }
          check_parameters(params, params_desc)
          source  = params[:source]
          args    = [source] + params[:args]
          lenient = params[:lenient]
          ok = system('python', *args) 
        end
        error "Error running Python source file '#{source}'" unless ok or lenient
      end

      # Check source files using Pychecker tool. You may find documentation
      # about this tool at this URL: http://pychecker.sourceforge.net/.
      #
      # - src: directory or list of directories containing Python source
      #   files to check.
      # - options: custom options to use on command line (optional).
      # - lenient: if set to true, doesn't interrupt the build on error.
      #   Optional, defaults to false.
      # - only: Tells if we must only check sources passed as parameters.
      #   Optional, defaults to true.
      #
      # Example
      #
      #  - python.pychecker:
      #      src:     ["lib", "test"]
      #      options: "--keepgoing"
      def pychecker(params)
        # check parameters
        params_desc = {
          :src       => { :mandatory => true,  :type => :string_or_array },
          :options   => { :mandatory => false, :type => :string },
          :lenient   => { :mandatory => false, :type => :boolean,
                          :default   => false },
          :only      => { :mandatory => false, :type => :boolean,
                          :default   => true }
        }
        check_parameters(params, params_desc)
        src       = params[:src]
        options   = params[:options]
        lenient   = params[:lenient]
        only      = params[:only]
        # build the list of python source files
        src = Array(src)
        files = []
        for dir in src
          files += Dir.glob("#{dir}/**/*.py")
        end
        files.map! { |file| "\"#{file}\"" }
        files.uniq!
        # run pychecker command
        puts "Checking #{files.length} Python source file(s)"
        command = "pychecker"
        command += " #{options}" if options
        command += " --only" if only
        command += " #{files.join(' ')}"
        puts "Running command: '#{command}'" if @verbose
        ok = system(command)
        error "Error checking Python source files" unless ok or lenient
      end

      # Check source files using Pylint tool. You may find documentation
      # about this tool at: http://www.logilab.org/card/pylint_tutorial.
      #
      # - src: directory or list of directories containing Python source
      #   files to check.
      # - files: a list of Python source files to check.
      # - path: a list of additional directories to include in Python path.
      #   Optional, defaults to no directory.
      # - options: custom options to use on command line (optional).
      # - lenient: if set to true, doesn't interrupt the build on error.
      #   Optional, defaults to false.
      # - config: configuration file name. Optional.
      #
      # Example
      #
      #  - python.pylint:
      #      src: "lib"
      def pylint(params)
        # check parameters
        params_desc = {
          :src       => { :mandatory => false, :type => :string_or_array },
          :files     => { :mandatory => false, :type => :string_or_array },
          :path      => { :mandatory => false, :type => :string_or_array },
          :options   => { :mandatory => false, :type => :string },
          :lenient   => { :mandatory => false, :type => :boolean,
                          :default   => false },
          :config    => { :mandatory => false, :type => :string_or_array },
        }
        check_parameters(params, params_desc)
        src       = params[:src]
        files     = params[:files]
        path      = params[:path]
        options   = params[:options]
        lenient   = params[:lenient]
        config    = params[:config]
        # build the list of python source files
        error "Must set at least one of 'src' or 'files' in python.pylint" if 
            not src and not files
        if files
            files = Array(files)
        else
            files = []
        end
        if src
            src = Array(src)
            for dir in src
                files += Dir.glob("#{dir}/**/*.py")
            end
        end
        # build the list of source directory to include them in PYTHONPATH
        dirs = []
        for file in files
            dir = File.expand_path(File.dirname(file))
            dirs << dir if not dirs.include?(dir)
        end
        dirs += path if path
        add_python_path(dirs)
        files.map! { |file| "\"#{file}\"" }
        files.uniq!
        # run pylint command
        puts "Checking #{files.length} Python source file(s)"
        command = "pylint"
        command += " --rcfile=#{config}" if config
        command += " #{options}" if options
        command += " #{files.join(' ')}"
        puts "Running command: '#{command}'" if @verbose
        ok = system(command)
        error "Error checking Python source files" unless ok or lenient
      end

      # Generate documentation using Epydoc tool.
      #
      # - src: directory or list of directories containing Python source
      #   files to doc for.
      # - dest: destination directory for generated documentation.
      # - options: custom options to use on command line (optional).
      #
      # Example
      #
      #  - python.pychecker:
      #      src:  ["lib", "test"]
      #      dest: "build/doc"
      def epydoc(params)
        # check parameters
        params_desc = {
          :src       => { :mandatory => true,  :type => :string_or_array },
          :dest      => { :mandatory => true,  :type => :string },
          :options   => { :mandatory => false, :type => :string },
        }
        check_parameters(params, params_desc)
        src       = params[:src]
        dest      = params[:dest]
        options   = params[:options]
        # build the list of python source files
        src = Array(src)
        files = []
        for dir in src
          files += Dir.glob("#{dir}/**/*.py")
        end
        files.map! { |file| "\"#{file}\"" }
        files.uniq!
        # make destination directory if it doesn't exist
        FileUtils.makedirs(dest) if not File.exists?(dest)
        error "epydoc 'dest' parameter must be a writable directory" unless
          File.directory?(dest) and File.writable?(dest)
        # run epydoc command
        puts "Generating doc for #{files.length} Python source file(s)"
        command = "epydoc"
        command += " -o #{dest}"
        command += " #{options}" if options
        command += " #{files.join(' ')}"
        puts "Running command: '#{command}'" if @verbose
        ok = system(command)
        error "Error generating documentation for Python source files" unless
          ok
      end

      # Run python test files. Parameter is a glob or list of globs for test
      # files to run.
      # 
      # Example
      # 
      #  - python.test: "test/test_*.py"
      def test(globs)
        error "python.test parameter is a String or Array of Strings" unless
          globs.kind_of?(String) or globs.kind_of?(Array)
        for glob in globs
          error "python.test parameter is a String or Array of Strings" unless
            glob.kind_of?(String)
          files = Dir.glob(glob)
          files.map! {|f| File.expand_path(f)}
          size = (files.kind_of?(Array) ? files.size : 1)
          puts "Running #{size} Python test file(s)" if files.length > 0
          script = File.join(File.expand_path(File.dirname(__FILE__)),
                             '..', 'tools', 'test', 'suite.py')
          command = "python #{script} #{files.join(' ')}"
          puts "Running command: '#{command}'" if @verbose
          ok = system(command)
          error "Error running Python test(s)" unless ok
        end
      end

      # Generate test coverage report.
      #
      # - src: directory or list of directories containing Python source
      #   files to measure test coverage for.
      # - test: glob or list of globs for tests to run while measuring
      #   coverage.
      # - dir: directory where to run unit tests. Optional, defaults to
      #   current directory. 
      # - dest: destination directory where to generate coverage report.
      #   Optional, will print report on console if not set.
      # - data: file where to write coverage data. Optional, defaults to
      #   file .coverage in current directory. MUST NOT be set in latest
      #   coverage versions because it doesn't implement this feature
      #   anymore.
      # - path: a list of directories to add to Python path to run tests.
      #
      # Example
      #
      #  - python.coverage:
      #      src:   "src"
      #      test:  "test/suite.py"
      #      dir:   "test"
      #      dest:  "build/coverage"
      #      path:  "lib"
      def coverage(params)
        # check parameters
        params_desc = {
          :src  => { :mandatory => true,  :type => :string_or_array },
          :test => { :mandatory => true,  :type => :string_or_array },
          :dir  => { :mandatory => true,  :type => :string },
          :dest => { :mandatory => false, :type => :string },
          :data => { :mandatory => false, :type => :string },
          :path => { :mandatory => false, :type => :string_or_array },
        }
        check_parameters(params, params_desc)
        src  = params[:src]
        test = params[:test]
        dir  = params[:dir]
        dest = params[:dest]
        data = params[:data]
        path = params[:path]
        path = path.map {|d| File.expand_path(d)} if path
        # manage directories and files
        src_files = []
        for src_dir in src
          error "Coverage 'src' parameter must be existing directories" unless
            File.exists?(src_dir) and File.directory?(src_dir)
          src_files += Dir.glob("#{src_dir}/**/*.py")
        end
        src_files = src_files.map {|f| File.expand_path(f)}.uniq.sort
        sources = src_files.join(' ')
        test_files = []
        for test_glob in test
          test_files += Dir.glob(test_glob)
        end
        test_files = test_files.map {|f| File.expand_path(f)}.uniq.sort
        error "Coverage 'dir' parameter must be an existing directory" unless
          File.exists?(dir) and File.directory?(dir)
        if dest
          dest = File.expand_path(dest)
          FileUtils.makedirs(dest) if not File.exists?(dest)
          report = File.join(dest, 'report.txt')
        end
        if path
          for path_dir in path
            error "Coverage 'path' parameter must be existing directories" unless
              File.exists?(path_dir) and File.directory?(path_dir)
          end
        end
        if data and data.length > 0
          data_opt = "-f #{data}"
        else
          data_opt = ''
        end
        # build the python path
        add_python_path(path)
        # run coverage command
        puts "Generating coverage report for #{test_files.length} test(s)..."
        prev_dir = Dir.pwd
        begin
          Dir.chdir(dir)
          # delete coverage data file
          if data and File.exists?(data)
            File.delete(data)
          elsif File.exists?('.coverage')
            File.delete('.coverage')
          end
          # run all tests
          for test_file in test_files
            command = "coverage run --append #{data_opt} #{test_file} 2>/dev/null"
            if @verbose
              puts "Running command: '#{command}'"
            else
              print '.'
            end
            system(command) || error("Error running coverage tests")
          end
          puts ''
          # generate coverage report
          command = "coverage report #{data_opt} -m #{sources}"
          puts "Running command: '#{command}'" if @verbose
          system(command) || error("Error generating coverage report")
          if dest
            # generate HTML report
            command = "coverage html #{data_opt} -d #{dest} #{sources}"
            puts "Running command: '#{command}'" if @verbose
            system(command) || error("Error generating coverage report")
          end
        ensure
          Dir.chdir(prev_dir)
        end
      end

      # Check Python dependencies using PIP (see http://pypi.python.org/pypi/pip).
      # Takes a single parameter that is the map of dependencies that gives version
      # for a given dependency. A version set to ~ (or nil) indicates that this
      # dependency is needed in any version (useful for developement libraries used
      # for development).
      #
      # Example:
      #
      #   - python.dependencies: { Django: "1.2.3", PyYAML: ~ }
      def dependencies(deps)
        error "python.dependencies parameter is a Map" unless
          deps.kind_of?(Hash)
        puts "Checking Python dependencies..."
        installed = installed_dependencies()
        check_dependencies(deps, installed)
      end

      # Check Python dependencies using PIP (see http://pypi.python.org/pypi/pip).
      # Takes a single parameter that is the requirements file name. A dependency
      # may specify no version, in this case we check that dependency in installed
      # in any version..
      #
      # Example:
      #
      #   - python.requirements: requirements.txt
      def requirements(reqs)
        error "python.requirements parameter is a string" unless
            reqs.kind_of?(String)
        puts "Checking Python requirements..."
        installed = installed_dependencies()
        content = File.read(reqs).strip
        dependencies = {}
        for line in content
          if line =~ /.+==.+/
            name, version = line.scan(/[^=]+/).map{|e| e.strip}
            dependencies[name] = version
          elsif line.strip.length > 0
            dependencies[line.strip] = nil
          end
        end
        check_dependencies(dependencies, installed)
      end

      private

      # Add directories to the Python path environment variable.
      # - dirs: directory (string) or list of directories to add to path.
      def add_python_path(dirs)
        if dirs and dirs.length > 0
          dirs = Array(dirs)
          puts "Adding to PYTHONPATH: '#{dirs.join(',')}'" if @verbose
          if ENV['PYTHONPATH']
            ENV['PYTHONPATH'] = dirs.join(File::PATH_SEPARATOR) +
              File::PATH_SEPARATOR + ENV['PYTHONPATH'] if dirs.length > 0
          else
            ENV['PYTHONPATH'] = dirs.join(File::PATH_SEPARATOR)
          end
        end
      end

      # Get installed dependencies running PIP and return them as a map
      # with dependencies names and versions.
      def installed_dependencies
        lines = `pip freeze`.strip.split("\n")
        installed = {}
        for line in lines
          if line =~ /^[^#].*/
            index = line.index('==')
            name = line[0..index-1]
            version = line[index+2..-1]
            installed[name] = version
          end
        end
        installed
      end

      # Check that dependencies (as a map) are installed. Throws an error if
      # not.
      def check_dependencies(dependencies, installed)
        for name in dependencies.keys.sort
          if installed.has_key?(name)
            if not dependencies[name] or dependencies[name] == '*'
              puts "#{name}: OK" if @verbose
            else
              if dependencies[name] != installed[name]
                error "Dependency '#{name}' in bad version ('#{installed[name]}' installed instead of '#{dependencies[name]}' required)"
              else
                puts "#{name} (#{dependencies[name]}): OK" if @verbose
              end
            end
          else
            error "Missing dependency '#{name}'"
          end
        end
      end

    end

  end

end
