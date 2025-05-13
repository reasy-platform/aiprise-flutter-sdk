// ignore_for_file: non_constant_identifier_names

class AiPriseThemeOptions {
  // Brand Color
  String? background;
  String? color_page; // For the background of the card on desktop
  String? color_brand;
  String? color_brand_overlay; // For the text / icons over the brand color

  // Font
  String? font_name; // Name of Google Font
  String? font_weights; // Comma separated list of font weights

  // Button
  String? button_border_radius;
  String? button_padding;
  String? button_font_size;
  String? button_font_weight;

  // Input
  String? input_border_radius;
  String? input_padding;
  String? input_font_size;
  String? input_font_weight;

  // Input Label
  String? input_label_font_size;
  String? input_label_font_weight;

  // Other
  String? layout_border_radius;
  String? modal_border_radius;
  String? image_border_radius;

  // Constructor
  AiPriseThemeOptions({
    // Brand Color
    this.background,
    this.color_page,
    this.color_brand,
    this.color_brand_overlay,

    // Font
    this.font_name,
    this.font_weights,

    // Button
    this.button_border_radius,
    this.button_padding,
    this.button_font_size,
    this.button_font_weight,

    // Input
    this.input_border_radius,
    this.input_padding,
    this.input_font_size,
    this.input_font_weight,
    this.input_label_font_size,
    this.input_label_font_weight,

    // Other
    this.layout_border_radius,
    this.modal_border_radius,
    this.image_border_radius,
  });

  // Convert to JSON
  Map<String, String?> toJson() => {
        // Brand Color
        if (background != null) 'background': background,
        if (color_page != null) 'color_page': color_page,
        if (color_brand != null) 'color_brand': color_brand,
        if (color_brand_overlay != null)
          'color_brand_overlay': color_brand_overlay,

        // Font
        if (font_name != null) 'font_name': font_name,
        if (font_weights != null) 'font_weights': font_weights,

        // Button
        if (button_border_radius != null)
          'button_border_radius': button_border_radius,
        if (button_padding != null) 'button_padding': button_padding,
        if (button_font_size != null) 'button_font_size': button_font_size,
        if (button_font_weight != null)
          'button_font_weight': button_font_weight,

        // Input
        if (input_border_radius != null)
          'input_border_radius': input_border_radius,
        if (input_padding != null) 'input_padding': input_padding,
        if (input_font_size != null) 'input_font_size': input_font_size,
        if (input_font_weight != null) 'input_font_weight': input_font_weight,
        if (input_label_font_size != null)
          'input_label_font_size': input_label_font_size,
        if (input_label_font_weight != null)
          'input_label_font_weight': input_label_font_weight,

        // Other
        if (layout_border_radius != null)
          'layout_border_radius': layout_border_radius,
        if (modal_border_radius != null)
          'modal_border_radius': modal_border_radius,
        if (image_border_radius != null)
          'image_border_radius': image_border_radius,
      };
}
