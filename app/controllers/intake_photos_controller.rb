class IntakePhotosController < ApplicationController
  def destroy
    repair = Repair.find(params[:repair_id])
    photo = repair.intake_photos.find(params[:id])
    photo.purge
    redirect_back_or_to repair, notice: "Photo removed from repair #{repair}.", status: :see_other
  end
end
