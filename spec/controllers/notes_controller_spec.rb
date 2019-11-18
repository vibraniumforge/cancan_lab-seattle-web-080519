require 'rails_helper'

RSpec.describe NotesController, type: :controller do
  before(:context) do
    @alice = User.find_or_create_by(YAML.load(file_fixture("users.yml").read)["alice"])
    @beth =  User.find_or_create_by(YAML.load(file_fixture("users.yml").read)["beth"])
    @content = 'secret message'
  end
  describe "Notes#create" do
    describe "when a user is not logged in" do
      it "returns unauthorized" do
        post :create, params: { note: { content: @content} }
        puts response.header
        expect(response).to be_unauthorized
      end
    end

    describe "when a user is logged in" do
      it "redirects to / after creation" do
        request.session[:user_id] = @alice.id
        post :create, params: { note: {content: @content, visible_to: ''} }
        expect(response).to redirect_to('/')
      end

      it "has the test content in the last message" do
        request.session[:user_id] = @alice.id
        post :create, params: { note: {content: @content, visible_to: ''} }
        note = Note.last
        expect(note.content).to eq(@content)
      end

      it "has the correct readers list" do
        request.session[:user_id] = @alice[:id]
        post :create, params: { note: {content: @content, visible_to: ''} }
        note = Note.last
        expect(note.readers.to_a).to eq([@alice])
      end

      it "is assigned to the creator" do
        request.session[:user_id] = @alice.id
        post :create, params: { note: {content: @content, visible_to: ''} }
        note = Note.last
        expect(note.user.id).to eq(@alice[:id])
      end
    end
  end
  describe "Notes#update" do
    describe "users can add additional reviewers of notes" do
      before(:context) {
        @note = Note.create(content: @content, visible_to: '')
        @note.user = @beth
        @note.save!
      }

      it "adds alice as a reader of beth's note" do
        request.session[:user_id] = @beth.id
        new_content = 'a different secret'
        post :update, params: { id: @note.id, note: {content: new_content, visible_to: 'alice'} }
        expect(response).to redirect_to('/')
      end

      it "adds alice as a reader of beth's note" do
        request.session[:user_id] = @beth.id
        new_content = 'a different secret'
        post :update, params: { id: @note.id, note: {content: new_content} }
        @note.reload # Rspec doesn't know to reload after update.
        expect(@note.content).to eq(new_content)
      end

      it "adds alice as a reader of beth's note" do
        request.session[:user_id] = @beth.id

        note = Note.create(content: @content, visible_to: '')
        note.user = @beth
        note.save!

        post :update, params: { id: note.id, note: {visible_to: 'alice'} }
        note.reload
        expect(note.visible_to).to match(@alice.name)
        expect(note.visible_to).to match(@beth.name)
      end
    end
  end
end
