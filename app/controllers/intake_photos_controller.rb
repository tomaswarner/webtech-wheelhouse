class IntakePhotosController < ApplicationController
  # Removing a photo is a front-desk edit of the repair (RepairPolicy#remove_photo?).
  # authorize runs before purge, so a refused request deletes nothing.
  def destroy
    repair = authorize Repair.find(params[:repair_id]), :remove_photo?
    photo = repair.intake_photos.find(params[:id])
    photo.purge
    redirect_back_or_to repair, notice: "Photo removed from repair #{repair}.", status: :see_other
  end
end
