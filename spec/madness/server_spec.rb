require 'spec_helper'

describe Server do
  before do 
    config.reset
    config.path = 'spec/fixtures/docroot'
  end

  it "works" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to have_tag 'h1', text: "This is a docroot fixture"
  end

  context "in subfolders" do
    it "works" do
      get '/Folder'
      expect(last_response).to be_ok
      expect(last_response.body).to have_tag 'h1', text: "Sub folder #1"
    end

    it "shows breadcrumbs" do
      get '/Folder'
      expect(last_response.body).to have_tag '.breadcrumbs' do
        with_tag 'a', text: 'Home'
        with_tag 'span', text: 'Folder'
      end
    end
  end

  context "with a nested file" do
    it "works" do
      get '/Folder/File'
      expect(last_response).to be_ok
      expect(last_response.body).to have_tag 'h1', text: "Nested File #1"
    end

    it "shows breadcrumbs" do
      get '/Folder/File'
      expect(last_response.body).to have_tag '.breadcrumbs' do
        with_tag 'a', text: 'Home'
        with_tag 'a', text: 'Folder'
        with_tag 'span', text: 'File'
      end
    end
  end

  context "in an empty folder" do
    it "shows index" do
      get '/Empty%20Folder'
      expect(last_response).to be_ok
      expect(last_response.body).to have_tag 'h1', text: /Empty Folder/
    end
  end

  context "in a folder with a single file" do
    it "redirects to the file" do
      get '/Redirect'
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to match /Redirect\/The%20only%20file%20here/
    end

    it "does not redirect if the file is README" do
      get '/No%20Redirect'
      expect(last_response).to be_ok
      expect(last_response.body).to have_tag 'p', text: "Was not redirected"
    end
  end

  describe "sass plugin" do
    let(:css) { 'app/public/css/main.css' }

    it "generates css in the public folder" do
      File.unlink css if File.exist? css
      expect(File).not_to exist css
      sleep 1
      get '/css/main.css'
      expect(File).to exist css      
    end
  end

end