require 'spec_helper'

describe BuildsController, '#create' do
  context 'when https is enabled' do
    context 'and http is used' do
      it 'does not redirect' do
        allow(JobQueue).to receive(:push)

        with_https_enabled do
          payload_data = File.read(
            'spec/support/fixtures/pull_request_opened_event.json'
          )
          post(:create, payload: payload_data)

          expect(response).not_to be_redirect
        end
      end
    end
  end

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
end
