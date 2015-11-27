module Bam
  class Deployment
    include BamHelpers
    PWD = Dir.pwd

    def initialize(server, to, from, dry_run, task_config)
      @from = from
      @server = server
      @to = to
      @dry_run = dry_run || false
      @task_config = task_config
    end

    def has_git?
      File.exists?(File.join PWD, ".git")
    end

    def has_git_ignores?
      File.exists?(File.join PWD, ".gitignore")
    end

    # gets a list of exclusions - exceptions
    def get_exclusions
      return "" if !has_git_ignores? || !has_git?   
      git_ignore = File.join PWD, ".gitignore"
      exclusions = `cat #{git_ignore}`.split("\n") 
      # ensure we remove any commented out .gitignores
      exclusions = exclusions.select { |exclusion| exclusion[0,1] != '#' }
      exclusions = exclusions - @task_config[:always_include] 
      if @dry_run
        puts wrap_top("EXCLUSIONS:")
        puts exclusions.join("\n") 
      end
      exclusions
    end

    def exclusions
      exclude_list = get_exclusions.map { |e| "--exclude '#{e}' " }
      exclude_list = exclude_list.join
      exclude_list
    end

    def remote_exec(name)
      remote_task = @task_config[:remote][name.to_sym]
      if remote_task.nil?
        puts "[REMOTE] TASK: #{name} does not exist"
      else
        exec_cmd = "ssh #{@server} '#{remote_task}'"
        puts @dry_run ? "[REMOTE] #{name} : #{remote_task}" : "[REMOTE] #{name}"
        system exec_cmd unless @dry_run
      end
    end

    def deploy
      puts "PRE-DEPLOYMENT TASKS: \n\n"
      deploy_tasks @task_config[:pre]
      puts(wrap_top("STARTING DEPLOYMENT:"))
      # use -avzC to exclude .git and .svn repositories
      cmd = "rsync -avzC #{@from} #{@server}:#{@to} #{exclusions}"
      output = "OUTPUT:\n#{cmd}"
      puts(wrap_borders(output))
      puts "POST-DEPLOYMENT TASKS: \n\n"
      deploy_tasks @task_config[:post]
      system(cmd) unless @dry_run
    end
    
    def deploy_tasks(tasks)
      if tasks.length > 0
        tasks.each do |task|
          remote_task = task.split("remote:")
          if remote_task.length > 1
            remote_exec remote_task[1]
          else 
            puts "[LOCAL] #{task}"
            `#{task}` unless @dry_run
          end
        end
      end
      puts "\n"
    end
    
  end
end