module Bam
  class Deployment
    include BamHelpers
    PWD = Dir.pwd

    def initialize(server, to, from, dry_run)
      @from = from
      @server = server
      @to = to
      @dry_run = dry_run || false
    end

    def has_git?
      File.exists?(File.join PWD, ".git")
    end

    def has_git_ignores?
      File.exists?(File.join PWD, ".gitignore")
    end

    # gets a list of exclusions - exceptions
    def get_exclusions(exceptions)
      return "" if !has_git_ignores? || !has_git?   
      git_ignore = File.join PWD, ".gitignore"
      exclusions = `cat #{git_ignore}`.split("\n") 
      exclusions - exceptions
    end

    def exclusions(exceptions)
      exclude_list = get_exclusions(exceptions).map { |e| "--exclude '#{e}' " }
      exclude_list = exclude_list.join
    end

    def deploy(exceptions)
      puts(wrap_top("STARTING DEPLOYMENT:"))
      # use -avzC to exclude .git and .svn repositories
      cmd = "rsync -avzC #{@from} #{@server}:#{@to} #{exclusions(exceptions)}"
      output = "OUTPUT: #{cmd}"
      puts(wrap_borders(output))
      system(cmd) unless @dry_run
    end
    
    def deploy_tasks(tasks)
      if tasks.length > 0
        tasks.each do |task|
          puts "[TASK] #{task}"
          `#{task}` unless @dry_run
        end
      end
      puts "\n"
    end
    
  end
end