package com.weather.demo.service;

import com.weather.demo.model.WeatherResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.json.JSONObject;

@Service
public class WeatherService {

    // Récupère les valeurs depuis application.properties
    @Value("${weather.api.key}")
    private String apiKey;

    @Value("${weather.api.url}")
    private String apiUrl;

    public WeatherResponse getWeather(String city) {
        // Construit l'URL de l'API OpenWeatherMap
        String url = apiUrl + "?q=" + city + "&appid=" + apiKey + "&units=metric&lang=fr";

        // Appelle l'API et récupère la réponse JSON
        RestTemplate restTemplate = new RestTemplate();
        String response = restTemplate.getForObject(url, String.class);

        // Parse le JSON
        JSONObject json = new JSONObject(response);

        // Construit notre objet réponse
        WeatherResponse weather = new WeatherResponse();
        weather.setCity(json.getString("name"));
        weather.setCountry(json.getJSONObject("sys").getString("country"));
        weather.setTemperature(json.getJSONObject("main").getDouble("temp"));
        weather.setDescription(json.getJSONArray("weather").getJSONObject(0).getString("description"));
        weather.setHumidity(json.getJSONObject("main").getInt("humidity"));
        weather.setWindSpeed(json.getJSONObject("wind").getDouble("speed"));

        return weather;
    }
}