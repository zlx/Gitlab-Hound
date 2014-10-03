require 'spec_helper'

describe RepoInitializer do
  before do
    
  end

  def stub_repo_sync
    sync = double("RepoSync", start: true)
    allow(RepoSynchronization).to receive(:new).and_return(sync)
    sync
  end

  def stub_repo_activator
    activator = double("RepoActivator", activate: true, deactivate: true)
    allow(RepoActivator).to receive(:new).and_return(activator)
    activator
  end

  def stub_repo repos
    repos.map { |repo| create(:repo, full_github_name: repo) }
  end

  def stub_active_repos active_repos
    Rails.application.secrets.active_repos = active_repos
  end

  it "should invoke RepoSynchronization#start & RepoActivator#activate" do
    sync = stub_repo_sync
    expect(sync).to receive(:start)
    activator = stub_repo_activator
    expect(activator).to receive(:activate)
    stub_repo ['mock/name']
    stub_active_repos ['mock/name']

    RepoInitializer.run
  end

  it "every run should activate active_repos" do
    stub_active_repos ['namespace1/name', 'namespace2/name']
    repos = stub_repo ['namespace1/name', 'namespace2/name']
    stub_repo_sync
    activator = stub_repo_activator
    expect(activator).to receive(:activate).with(repos.first)
    expect(activator).to receive(:activate).with(repos.last)

    RepoInitializer.run
  end
  
  it "should deactivate unactive_repos" do
    stub_repo_sync
    repo = create(:repo, :active, full_github_name: 'namespace2/name')

    stub_active_repos ['namespace1/name' ]
    stub_repo ['namespace1/name']
    activator = stub_repo_activator
    expect(activator).to receive(:deactivate).with(kind_of(Repo))

    RepoInitializer.run
  end

end
