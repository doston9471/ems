# frozen_string_literal: true

module My
  class EmergencyContactsController < BaseController
    skip_after_action :verify_authorized
    before_action :set_contact, only: %i[edit update destroy]

    def index
      @contacts = Current.employee.emergency_contacts.order(primary: :desc, name: :asc)
    end

    def new
      @contact = Current.employee.emergency_contacts.new
    end

    def create
      @contact = Current.employee.emergency_contacts.new(contact_params)
      if @contact.save
        redirect_to my_emergency_contacts_path, notice: "Emergency contact added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @contact.update(contact_params)
        redirect_to my_emergency_contacts_path, notice: "Emergency contact updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @contact.destroy!
      redirect_to my_emergency_contacts_path, notice: "Emergency contact removed."
    end

    private

    def set_contact
      @contact = Current.employee.emergency_contacts.find(params[:id])
    end

    def contact_params
      params.require(:emergency_contact).permit(:name, :relationship, :phone, :email, :primary)
    end
  end
end
