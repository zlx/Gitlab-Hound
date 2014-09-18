require 'fast_spec_helper'
require 'app/workers/small_build_job'

describe SmallBuildJob do

  describe '.perform' do
    it 'runs build runner' do
      payload_data = double(:payload_data)
      payload = double(:payload)
      build_runner = double(:build_runner, run: nil)
      allow(GitlabPayload).to receive(:new).and_return(payload)
      allow(BuildRunner).to receive(:new).and_return(build_runner)

      SmallBuildJob.new.perform(payload_data)

      expect(GitlabPayload).to have_received(:new).with(payload_data)
      expect(BuildRunner).to have_received(:new).with(payload)
      expect(build_runner).to have_received(:run)
    end
  end
end
