package com.example.pixel_weather_forecast

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Renders the PNG that Dart pre-rendered via `HomeWidget.renderFlutterWidget`
 * (see lib/data/home_widget_service.dart) into the widget's one ImageView.
 * There is no native layout logic here on purpose — the pixel-art look
 * lives entirely in the Flutter side so it can't drift from the app.
 */
class WeatherWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.weather_widget).apply {
            val pendingIntent =
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            val imagePath = widgetData.getString("weather_widget_image", null)
            if (imagePath != null) {
              setImageViewBitmap(R.id.widget_img, BitmapFactory.decodeFile(imagePath))
            }
          }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
