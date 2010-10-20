module Bam
  class Deployment
    include BamHelpers
    PWD = Dir.pwd

    def initialize(server, to, from)
      @from = from
      @server = server
      @to = to
    end

    def has_git?
      File.exists?(File.join PWD, ".git")
    end

    def has_git_ignores?
      File.exists?(File.join PWD, ".gitignore")
    end

    def exclusions
      return "" if !has_git_ignores? || !has_git?
      git_ignore = File.join PWD, ".gitignore"
      exclusions = `cat #{git_ignore}`.split("\n")
      exclude_list = exclusions.map { |e| "--exclude '#{e}' " }
      exclude_list = exclude_list.join
    end

    def deploy
      puts("Starting deployment...")
      # use -avzC to exclude .git and .svn repositories
      cmd = "rsync -avzC #{@from} #{@server}:#{@to} #{exclusions}"
      output = "OUTPUT: #{cmd}"
      puts(wrap_borders(output))
      system(cmd)
    end
    
    def deploy_tasks(tasks)
      if tasks.length > 0
        tasks.each do |task|
          puts "  - Executing deployment task: #{task}"
          `#{task}`
        end
      end
    end
    
  end
end