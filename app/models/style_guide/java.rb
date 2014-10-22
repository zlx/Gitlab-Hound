module StyleGuide
  class Java < Base

    def violations_in_file(file)
      team.lint(file.content).compact.map do |violation|
        Violation.new(file, violation[1], violation[0])
      end
    end

    private
    def config_content
      repo_config.for(name)
    end

    def team
      @team ||= Jlint.new(config_content)
    end
  end
end
