class MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_management!, except: [:new, :create]
  before_filter :search
  # GET /members
  # GET /members.json

  def index
    @members = Member.all
    @member = current_management
    @cMembers = Member.where(confirm: "NC")
    @iMembers = Member.where(inside: "on")

    @iMembers.each do |member| 
      if Time.now.to_i - member.updated_at.to_i > 10 
        member.update_attribute(:inside, "off") 
      end 
    end 
    @tMembers = Member.order(useRate: :desc).limit(5)
    @asd = CardInfo.all
  end

  def show
  end

  def generate_cardId
    for i in 1..150
      CardInfo.create(cardId: i)
    end
  end

  def confirm
   @member = Member.find(params[:member_id])
   @member.update_attribute(:confirm, "YC")
   redirect_to members_url
 end

 def search
  @q = Member.search(params[:q])
  @members = @q.result
end

def new
  @member = Member.new
end

def edit
end


def create
  @member = Member.new(member_params)
  if CardInfo.exists?(:cardId => @member.cardId)
    respond_to do |format|
      if @member.save
        format.html { redirect_to root_path, notice: 'Member was successfully created.' }
        format.json { render :new, status: :created, location: @member }
        @member.update_attributes(:confirm => "NC", :useRate => 0, :inside => "off", :entryDate => 0)
      else
        format.html { render :new }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
      CardInfo.where(cardId: @member.cardId).destroy_all
    end
  end
end

def update
  respond_to do |format|
    if @member.update(member_params)
      format.html { redirect_to @member, notice: 'Member was successfully updated.' }
      format.json { render :show, status: :ok, location: @member }
    else
      format.html { render :edit }
      format.json { render json: @member.errors, status: :unprocessable_entity }
    end
  end
end

def destroy
  @member.destroy
  respond_to do |format|
    format.html { redirect_to members_url, notice: 'Member was successfully destroyed.' }
    format.json { head :no_content }
    CardInfo.create(cardId: @member.cardId)
  end
end

private

def set_member
  @member = Member.find(params[:id])
end

def member_params
  params.require(:member).permit(:cardId, :email, :name, :lastname, :confirm, :useRate, :inside, :entryDate, :memberDate, :image)

end
end
