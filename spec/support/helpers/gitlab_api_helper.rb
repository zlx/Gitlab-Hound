module GitlabApiHelper
  def stub_get url, file
    stub_request(:get, url).with(
      headers: { 'Accept' => 'application/json', 'Private-Token' => auth_token }
    ).to_return(
      status: 200,
      body: load_fixture(file),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_post(url, file)
    stub_request(:post, url).with(
      headers: { 'Accept' => 'application/json', 'Private-Token' => auth_token },
    ).to_return(
      status: 200,
      body: load_fixture(file),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  private
  def auth_token
    'authtoken'
  end

  def load_fixture file
    File.read("spec/support/fixtures/#{file}.json")
  end

end
