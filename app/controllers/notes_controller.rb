class NotesController < ApplicationController
  load_and_authorize_resource only: [:show, :edit, :update, :index]

  def index
    @notes = Note.none
    if current_user
      @notes = current_user.readable
    end
  end

  def show
  end

  def new
    render partial: 'form', locals: {note: Note.new}
  end

  def create
    if user_is_not_signed_in?
      return head(:unauthorized)
    end
    @note = Note.new(note_params)
    @note.user = current_user
    if @note.save!
      redirect_to '/'
    else
      puts @note.errors.full_messages
      render :new
    end
  end

  def edit
  end

  def update
  
    @note = Note.find(params[:id])
    @note.update(note_params)
    if @note.save
      redirect_to '/'
    else
      puts @note.errors.full_messages
      render :new
    end
  end

  def destroy
  end

  private

  def note_params
    params.require(:note).permit(:content, :visible_to)
  end

end