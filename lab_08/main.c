#include <gtk/gtk.h>
#include <stdlib.h>

#define WINDOW_TITLE "ЛР8 по МЗЯП. Попов Ю.А."
#define LABEL_TEXT "Введитеё текст: "
#define BUTTON_TEXT "Найти ближайшую сверху степень двойки"
#define RESULT_TEXT "Результат"
#define ERR_NUMBER_TEXT "Ошибка, нужно ввести безнаковое число"
#define WIDTH 300
#define HEIGHT 100

#define ERR_OK 0
#define ERR_NUMBER 1

static void on_dialog_response(GtkDialog *dialog, gint response_id, gpointer user_data)
{
    gtk_widget_destroy(GTK_WIDGET(dialog));
}

int find_upper_degree_of_two(long long num)
{
    int a = 1;
    int count = 0;
    while (a < num)
    {
        a <<= 1;
        count++;
    }

    return count;
}

static void on_button_clicked(GtkWidget *widget, gpointer data)
{
    GtkWidget *entry = (GtkWidget *)data;
    GtkWidget *label = g_object_get_data(G_OBJECT(entry), "label");
    GtkWidget *msg_dialog;

    const char *text = gtk_entry_get_text(GTK_ENTRY(entry));

    char *end = NULL;
    long long number = strtoll(text, &end, 10);

    if (*end != 0 || number < 0)
    {
        msg_dialog = gtk_message_dialog_new(
            NULL, GTK_DIALOG_MODAL, GTK_MESSAGE_ERROR, GTK_BUTTONS_OK, ERR_NUMBER_TEXT);
        gtk_window_set_title(GTK_WINDOW(msg_dialog), "Ошибка");
        g_signal_connect(msg_dialog, "response", G_CALLBACK(on_dialog_response), NULL);
        gtk_widget_show_all(msg_dialog);
    }
    else
    {
        int degree = find_upper_degree_of_two(number);
        msg_dialog = gtk_message_dialog_new(
            NULL, GTK_DIALOG_MODAL, GTK_MESSAGE_INFO, GTK_BUTTONS_OK, "Ближайшая степень двойки %d : 2^%d = %lld", degree, degree, (1LL << degree));
        gtk_window_set_title(GTK_WINDOW(msg_dialog), "Результат");
        g_signal_connect(msg_dialog, "response", G_CALLBACK(on_dialog_response), NULL);
        gtk_widget_show_all(msg_dialog);
    }
}

int main(int argc, char **argv)
{
    GtkWidget *window;
    GtkWidget *grid;
    GtkWidget *button;
    GtkWidget *label;
    GtkWidget *entry;

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

    g_signal_connect(button, "clicked", G_CALLBACK(on_button_clicked), entry);

    gtk_widget_show_all(window);
    gtk_main();
    return 0;
}
