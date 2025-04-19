#include <gtk/gtk.h>

#define WINDOW_TITLE "ЛР8 по МЗЯП. Попов Ю.А."
#define LABEL_TEXT "Введите текст: "
#define BUTTON_TEXT "Найти ближайшую сверху степень двойки"
#define RESULT_TEXT "Результат"
#define WIDTH 300
#define HEIGHT 150

static void on_button_clicked(GtkWidget *widget, gpointer data)
{
    GtkWidget *entry = (GtkWidget *)data;
    GtkWidget *label = g_object_get_data(G_OBJECT(entry), "label");

    const gchar *text = gtk_entry_get_text(GTK_ENTRY(entry));
    gtk_label_set_text(GTK_LABEL(label), text);
}

int main(int argc, char **argv)
{
    GtkWidget *window;
    GtkWidget *grid;
    GtkWidget *button;
    GtkWidget *label;
    GtkWidget *entry;
    GtkWidget *res;

    gtk_init(&argc, &argv);

    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window), WINDOW_TITLE);
    gtk_window_set_default_size(GTK_WINDOW(window), WIDTH, HEIGHT);

    g_signal_connect(window, "destroy", G_CALLBACK(gtk_main_quit), NULL);

    grid = gtk_grid_new();
    gtk_container_add(GTK_CONTAINER(window), grid);

    label = gtk_label_new(LABEL_TEXT);
    gtk_grid_attach(GTK_GRID(grid), label, 0, 0, 1, 1);

    entry = gtk_entry_new();
    gtk_grid_attach(GTK_GRID(grid), entry, 1, 0, 1, 1);

    button = gtk_button_new_with_label(BUTTON_TEXT);
    gtk_grid_attach(GTK_GRID(grid), button, 0, 1, 2, 1);

    res = gtk_label_new(RESULT_TEXT);
    gtk_grid_attach(GTK_GRID(grid), res, 0, 2, 1, 1);

    // Сохраняем указатель на label в entry (чтобы получить его в callback)
    g_object_set_data(G_OBJECT(entry), "label", res);
    g_signal_connect(button, "clicked", G_CALLBACK(on_button_clicked), entry);

    gtk_widget_show_all(window);
    gtk_main();
    return 0;
}