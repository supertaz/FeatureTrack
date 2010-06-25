class ReleaseNotesController < ApplicationController
  def index
    @release_notes = ReleaseNote.all
  end
  
  def show
    @release_note = ReleaseNote.find(params[:id])
  end
  
  def new
    @release_note = ReleaseNote.new
  end
  
  def create
    @release_note = ReleaseNote.new(params[:release_note])
    if @release_note.save
      flash[:notice] = "Successfully created release note."
      redirect_to @release_note
    else
      render :action => 'new'
    end
  end
  
  def edit
    @release_note = ReleaseNote.find(params[:id])
  end
  
  def update
    @release_note = ReleaseNote.find(params[:id])
    if @release_note.update_attributes(params[:release_note])
      flash[:notice] = "Successfully updated release note."
      redirect_to @release_note
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @release_note = ReleaseNote.find(params[:id])
    @release_note.destroy
    flash[:notice] = "Successfully destroyed release note."
    redirect_to release_notes_url
  end
end
