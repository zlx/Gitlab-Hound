require 'spec_helper'

describe PushEventsJob do

  it "should enqueue small_build_job" do
    gitlab_payload = double("gitlabpayload", data: {})
    allow(GitlabPushPayload).to receive_message_chain(:new, :to_gitlab_payload => gitlab_payload)
    PushEventsJob.new.perform({})
    expect(SmallBuildJob.jobs.count).to eq 1
  end

  it "should not enqueue small_build_job" do
    allow(GitlabPushPayload).to receive_message_chain(:new, :to_gitlab_payload => nil)
    PushEventsJob.new.perform({})
    expect(SmallBuildJob.jobs.count).to eq 0
  end

end
