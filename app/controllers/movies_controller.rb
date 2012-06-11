class MoviesController < ApplicationController
  helper_method :selected_ratings, :movie_query, :session_filtering

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # @all_ratings = Movie.select('DISTINCT rating').map(&:rating)
    @all_ratings = Movie.ratings
    @sel_ratings = selected_ratings
    session_filtering # Do all the session stuff
    @movies = movie_query
  end

  def selected_ratings
    if params[:ratings]
      params[:ratings]
    else
      Hash.new(0)
    end
  end

  def movie_query
    sort_by, sort_by_direction = params[:sort], params[:direction]

    if sort_by && sort_by_direction && !@sel_ratings.empty?
      Movie.where("rating" => @sel_ratings.keys).order(sort_by + " " + sort_by_direction)
    elsif sort_by && sort_by_direction && @sel_ratings.empty?
      Movie.order(sort_by + " " + sort_by_direction)
    elsif not @sel_ratings.empty?
      Movie.where("rating" => @sel_ratings.keys)
    else
      Movie.find(:all)
    end
  end

  def session_filtering
    if !session[:ratings].is_a?(Hash) then session[:ratings] = Hash.new(0) end
    if params[:sort] then session[:sort] = params[:sort] end
    if params[:direction] then session[:direction] = params[:direction] end
    if params[:commit] then session[:ratings] = @sel_ratings end

    if (not params[:sort] && params[:direction]) && session[:sort] && session[:direction]
      if session[:ratings].empty?
        flash.keep
        redirect_to movies_path(:sort => session[:sort], :direction => session[:direction])
      else
        flash.keep
        redirect_to movies_path(:sort => session[:sort], :direction => session[:direction], :ratings => session[:ratings])
      end
    elsif (not params[:sort] && params[:direction]) && !session[:ratings].empty?
      flash.keep
      redirect_to movies_path(:ratings => session[:ratings])
    elsif params[:sort] && params[:direction] && (not params[:ratings]) && !session[:ratings].empty?
      flash.keep
      redirect_to movies_path(:sort => params[:sort], :direction => params[:direction], :ratings => session[:ratings])
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
