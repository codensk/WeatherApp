//
//  CityTableViewController.swift
//  WeatherApp
//

import UIKit

enum Identifier: String {
    case cityCell = "cityCell"
    case detailsVC = "detailsVC"
}

class CityTableViewController: UITableViewController {
    // MARK: - Properties
    private var searchController = UISearchController(searchResultsController: nil)
    private var cities: [City]!
    private var filteredCities = [City]()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cities = City.getDemoCities()
        filteredCities = cities
        
        configureNavigationBar()
        configureSearchBar()
        configureTableView()
        configureUIView()
    }
    
    // MARK: - Methods
    
    private func configureUIView() {
        view.backgroundColor = UIColor(named: "dayGradientEnd")
        tableView.tableFooterView = UIView()
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addCityButtonTapped))
        
        title = "Выберите город"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor =  UIColor(named: "dayGradientEnd")
    }
    
    private func configureSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск города"
        searchController.searchBar.backgroundColor =  UIColor(named: "dayGradientEnd")
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController = UISearchController(searchResultsController: nil)
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func configureTableView() {
        tableView.rowHeight = 73
    }
    
    @objc private func addCityButtonTapped() {
        let alert = UIAlertController(title: "Введите название города", message: nil, preferredStyle: .alert)
        
        let appendButton = UIAlertAction(title: "Добавить", style: .default) {
            (action) in
        //    Получаем текст из TextField
//            let textField = alert.textFields?.first
            
        }
        
        let cancelButton = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(appendButton)
        alert.addAction(cancelButton)
        
        alert.addTextField {(textField) in
            textField.placeholder = "Название города"
        }
        
        present(alert, animated: true)
    }
}

// MARK: - Extensions
extension CityTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.cityCell.rawValue, for: indexPath) as! CityTableViewCell

        let cityWeather =  filteredCities[indexPath.row]
        cell.backgroundColor = .clear
        cell.cityNameLabel.text = cityWeather.cityName
        
        // тут запрашиваем у сервиса погоду для города в списке
        WeatherService.shared.fetchCityWeather(for: cityWeather.cityName) { result, error in
            guard error == nil, let result = result else {
                return
            }
            
            self.filteredCities[indexPath.row].weatherData = result
            
            DispatchQueue.main.async {
                guard let cityWeaherData = self.filteredCities[indexPath.row].weatherData else {
                    return
                }
                
                if cityWeaherData.weather.indices.contains(0) {
                    let weather = cityWeaherData.weather[0]
                    
                    cell.weatherDescriptionLabel.text = weather.weatherDescription
                    cell.temperatureLabel.text = "\(String(format: "%.1f", result.main.temp))º"
                }
              
            }
        }
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailsVC = storyboard?.instantiateViewController(identifier: Identifier.detailsVC.rawValue) as? DetailsViewController else {
            return
        }
        detailsVC.city = filteredCities[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
}

extension CityTableViewController: UISearchResultsUpdating {
     func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! == "" {
            filteredCities = cities
        } else {
            filteredCities = cities.filter({ $0.cityName.lowercased().contains(searchController.searchBar.text!.lowercased()) })
        }
        
        self.tableView.reloadData()
    }
}
