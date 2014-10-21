module StyleGuide
  class Java < Base

    def violations_in_file(file)
      Jlint.lint(file.content, "").compact.map do |violation|
        Violation.new(file, violation[1], violation[0])
      end
    end
  end
end
