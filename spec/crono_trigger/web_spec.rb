require "spec_helper"
require "crono_trigger/web"
require "rack/mock"

RSpec.describe CronoTrigger::Web do
  shared_examples "JSON endpoints" do
    let(:req) { Rack::MockRequest.new(described_class) }

    let!(:signal) do
      CronoTrigger::Models::Signal.create!(
        worker_id: "w1",
        signal: "TERM",
        sent_at: Time.utc(2000, 1, 2, 3, 4, 5),
      )
    end

    after { signal.delete }

    it "GET /signals.json" do
      res = req.get("/signals.json")

      expect(res.status).to eq(200)
      expect(res.content_type).to eq("application/json")
      expect(JSON.parse(res.body)).to match(
        "records" => [a_hash_including("sent_at" => "2000-01-02T03:04:05.000Z")],
      )
    end

    it "GET /models.json" do
      res = req.get("/models.json")

      expect(res.status).to eq(200)
      expect(res.content_type).to eq("application/json")
      expect(JSON.parse(res.body)).to match("models" => [String])
    end
  end

  context "when Oj is available" do
    it "loads Oj" do
      expect(defined?(Oj)).to eq("constant")
    end

    include_examples "JSON endpoints"
  end

  context "when Oj is not available" do
    before { hide_const("Oj") }

    include_examples "JSON endpoints"
  end
end
