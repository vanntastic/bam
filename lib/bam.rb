module Bam
  class Deployment
    PWD = Dir.pwd

    def initialize(server, to, from=nil)
      @from = PWD if from.nil?
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

    # terminal column width
    def col_width
      `stty size`.split(" ").last.to_i
    end

    def deploy
      puts("Starting deployment...")
      # use -avzC to exclude .git and .svn repositories
      cmd = "rsync -avzC #{@from} #{@server}:#{@to} #{exclusions}"
      output = "OUTPUT: #{cmd}"
      border = "="*col_width
      puts("#{border}\n#{output}\n#{border}")
      system(cmd)
    end
  end
end