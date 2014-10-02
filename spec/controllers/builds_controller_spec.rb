require 'spec_helper'

describe BuildsController, '#create' do
  it 'enqueues small build job' do
    allow(JobQueue).to receive(:push)
    payload_data = File.read(
      'spec/support/fixtures/pull_request_opened_event.json'
    )

    post :create, JSON.parse(payload_data)

    expect(JobQueue).to have_received(:push).with(
      SmallBuildJob,
      kind_of(Hash)
    )
  end

  it 'enqueues push events job' do
    allow(JobQueue).to receive(:push)
    payload_data = File.read(
      'spec/support/fixtures/push_events.json'
    )

    post :create, JSON.parse(payload_data)

    expect(JobQueue).to have_received(:push).with(
      PushEventsJob,
      kind_of(Hash)
    )
  end
end
