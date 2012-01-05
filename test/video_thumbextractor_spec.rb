require File.expand_path("./spec_helper", File.dirname(__FILE__))
require 'net/http'
require 'uri'

describe "when getting a thumb" do

  describe "and module is enabled" do
    it "should return a image" do
      EventMachine.run do
        req = EventMachine::HttpRequest.new(nginx_address + '/test_video.mp4?second=2').get :timeout => 10
        req.callback do
          req.response_header.status.should eq(200)
          req.response_header.content_length.should_not eq(0)
          req.response_header["CONTENT_TYPE"].should eq("image/jpeg")

          EventMachine.stop
        end
      end
    end

    describe "and manipulating 'filename' configuration" do
      let!(:configuration) do
        @video_filename = "$http_x_filename"
      end

      it "should accept complex values" do
        EventMachine.run do
          req = EventMachine::HttpRequest.new(nginx_address + '/?second=2').get :head => {"x-filename" => '/test_video.mp4'} ,:timeout => 10
          req.callback do
            req.response_header.status.should eq(200)
            req.response_header.content_length.should_not eq(0)
            req.response_header["CONTENT_TYPE"].should eq("image/jpeg")

            EventMachine.stop
          end
        end
      end
    end

    describe "and manipulating 'second' configuration" do
      let!(:configuration) do
        @video_second = "$http_x_second"
      end

      it "should accept complex values" do
        EventMachine.run do
          req = EventMachine::HttpRequest.new(nginx_address + '/test_video.mp4').get :head => {"x-second" => 2} ,:timeout => 10
          req.callback do
            req.response_header.status.should eq(200)
            req.response_header.content_length.should_not eq(0)
            req.response_header["CONTENT_TYPE"].should eq("image/jpeg")

            EventMachine.stop
          end
        end
      end

      it "should return 404 when second is greather than duration" do
        EventMachine.run do
          req = EventMachine::HttpRequest.new(nginx_address + '/test_video.mp4').get :head => {"x-second" => 20} ,:timeout => 10
          req.callback do
            req.response_header.status.should eq(404)
            req.response_header.content_length.should_not eq(0)
            req.response_header["CONTENT_TYPE"].should eq("text/html")

            EventMachine.stop
          end
        end
      end

      it "should retturn different images for two different seconds" do
        EventMachine.run do
          req = EventMachine::HttpRequest.new(nginx_address + '/test_video.mp4').get :head => {"x-second" => 2} ,:timeout => 10
          req.callback do
            req.response_header.status.should eq(200)
            req.response_header.content_length.should_not eq(0)
            req.response_header["CONTENT_TYPE"].should eq("image/jpeg")

            image = req.response

            req_1 = EventMachine::HttpRequest.new(nginx_address + '/test_video.mp4').get :head => {"x-second" => 4} ,:timeout => 10
            req_1.callback do
              req_1.response_header.status.should eq(200)
              req_1.response_header.content_length.should_not eq(0)
              req_1.response_header["CONTENT_TYPE"].should eq("image/jpeg")

              req_1.response.should_not eq(image)

              EventMachine.stop
            end
          end
        end
      end
    end

    describe "and manipulating 'width' configuration" do
      let!(:configuration) do
        @image_width = "$http_x_width"
      end

      it "should accept complex values" do
        EventMachine.run do
          req = EventMachine::HttpRequest.new(nginx_address + '/test_video.mp4?second=2').get :head => {"x-width" => 100} ,:timeout => 10
          req.callback do
            req.response_header.status.should eq(200)
            req.response_header.content_length.should_not eq(0)
            req.response_header["CONTENT_TYPE"].should eq("image/jpeg")

            EventMachine.stop
          end
        end
      end

      it "should reject width less than 16px" do
        EventMachine.run do
          req = EventMachine::HttpRequest.new(nginx_address + '/test_video.mp4?second=2').get :head => {"x-width" => 15} ,:timeout => 10
          req.callback do
            req.response_header.status.should eq(400)
            req.response_header.content_length.should_not eq(0)
            req.response_header["CONTENT_TYPE"].should eq("text/html")

            EventMachine.stop
          end
        end
      end

      it "should return an image with full size if zero value is given" do
        EventMachine.run do
          req = EventMachine::HttpRequest.new(nginx_address + '/test_video.mp4?second=2').get :head => {"x-width" => 0} ,:timeout => 10
          req.callback do
            req.response_header.status.should eq(200)

            req.response.should eq(image('/test_video.mp4?second=2'))

            EventMachine.stop
          end
        end
      end

      it "should return an image with full size if negative value is given" do
        EventMachine.run do
          req = EventMachine::HttpRequest.new(nginx_address + '/test_video.mp4?second=2').get :head => {"x-width" => -15} ,:timeout => 10
          req.callback do
            req.response_header.status.should eq(200)

            req.response.should eq(image('/test_video.mp4?second=2'))

            EventMachine.stop
          end
        end
      end
    end

    describe "and manipulating 'height' configuration" do
      let!(:configuration) do
        @image_height = "$http_x_height"
      end

      it "should accept complex values" do
        EventMachine.run do
          req = EventMachine::HttpRequest.new(nginx_address + '/test_video.mp4?second=2').get :head => {"x-height" => 100} ,:timeout => 10
          req.callback do
            req.response_header.status.should eq(200)
            req.response_header.content_length.should_not eq(0)
            req.response_header["CONTENT_TYPE"].should eq("image/jpeg")

            EventMachine.stop
          end
        end
      end

      it "should reject height less than 16px" do
        EventMachine.run do
          req = EventMachine::HttpRequest.new(nginx_address + '/test_video.mp4?second=2').get :head => {"x-height" => 15} ,:timeout => 10
          req.callback do
            req.response_header.status.should eq(400)
            req.response_header.content_length.should_not eq(0)
            req.response_header["CONTENT_TYPE"].should eq("text/html")

            EventMachine.stop
          end
        end
      end

      it "should return an image with full size if zero value is given" do
        EventMachine.run do
          req = EventMachine::HttpRequest.new(nginx_address + '/test_video.mp4?second=2').get :head => {"x-height" => 0} ,:timeout => 10
          req.callback do
            req.response_header.status.should eq(200)

            req.response.should eq(image('/test_video.mp4?second=2'))

            EventMachine.stop
          end
        end
      end

      it "should return an image with full size if negative value is given" do
        EventMachine.run do
          req = EventMachine::HttpRequest.new(nginx_address + '/test_video.mp4?second=2').get :head => {"x-height" => -15} ,:timeout => 10
          req.callback do
            req.response_header.status.should eq(200)

            req.response.should eq(image('/test_video.mp4?second=2'))

            EventMachine.stop
          end
        end
      end

      it "should return an image with relative size if only height is given" do
        EventMachine.run do
          req = EventMachine::HttpRequest.new(nginx_address + '/test_video.mp4?second=2').get :head => {"x-height" => 360} ,:timeout => 10
          req.callback do
            req.response_header.status.should eq(200)

            req.response.should eq(image('/test_video.mp4?second=2'))

            EventMachine.stop
          end
        end
      end

      it "should return an image with specified size if height and width are given" do
        EventMachine.run do
          req = EventMachine::HttpRequest.new(nginx_address + '/test_video.mp4?second=2' + '&width=200').get :head => {"x-height" => 360} ,:timeout => 10
          req.callback do
            req.response_header.status.should eq(200)

            req.response.should_not eq(image('/test_video.mp4?second=2'))

            EventMachine.stop
          end
        end
      end
    end
  end

  describe "and module is disabled" do
    let!(:configuration) do
      @thumbextractor = nil
    end

    it "should return a video" do
      EventMachine.run do
        req = EventMachine::HttpRequest.new(nginx_address + '/test_video.mp4?second=2').get :timeout => 10
        req.callback do
          req.response_header.status.should eq(200)
          req.response_header.content_length.should_not eq(0)
          req.response_header["CONTENT_TYPE"].should eq("video/mp4")

          EventMachine.stop
        end
      end
    end
  end

end

def image(url)
  url = URI.parse(nginx_address + url)
  the_request = Net::HTTP::Get.new(url.request_uri)
  the_response = Net::HTTP.start(url.host, url.port) { |http| http.request(the_request) }
  the_response.body
end