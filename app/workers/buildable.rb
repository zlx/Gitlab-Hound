module Buildable

  def perform(payload_data)
    payload = GitlabPayload.new(payload_data)
    build_runner = BuildRunner.new(payload)
    build_runner.run
  end
end
