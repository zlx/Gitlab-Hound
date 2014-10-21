class Commit
  pattr_initialize :repo_name, :payload, :github
  attr_reader :repo_name

  def files
    @files ||= github_files.map { |file| build_commit_file(file) }
  end

  def sha
    github.branch_commit(payload.source_repo_id, payload.branch_name)
  end

  def file_content(filename)
    @github.file_contents(repo_name, filename, sha).to_s.force_encoding("UTF-8")
  rescue Gitlab::Error::Error
    ""
  end

  private

  def build_commit_file(file)
    CommitFile.new(file, self)
  end

  def github_files
    @github.commit_files(repo_name, sha)
  end
end
