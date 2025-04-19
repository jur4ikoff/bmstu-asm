#include <gtk/gtk.h>

// Callback-функция для кнопки
static void on_button_clicked(GtkWidget *widget, gpointer data) {
    GtkWidget *entry = (GtkWidget *)data;
    GtkWidget *label = g_object_get_data(G_OBJECT(entry), "label");
    
    const gchar *text = gtk_entry_get_text(GTK_ENTRY(entry));
    gtk_label_set_text(GTK_LABEL(label), text);
}

int main(int argc, char *argv[]) {
    GtkWidget *window;
    GtkWidget *grid;
    GtkWidget *button;
    GtkWidget *label;
    GtkWidget *entry;

    // Инициализация GTK
    gtk_init(&argc, &argv);

    // Создание главного окна
    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window), "GTK-3 Test Program");
    gtk_window_set_default_size(GTK_WINDOW(window), 300, 200);
    g_signal_connect(window, "destroy", G_CALLBACK(gtk_main_quit), NULL);

    // Создание контейнера Grid (для расположения виджетов)
    grid = gtk_grid_new();
    gtk_container_add(GTK_CONTAINER(window), grid);

    // Создание метки (Label)
    label = gtk_label_new("Введите текст:");
    gtk_grid_attach(GTK_GRID(grid), label, 0, 0, 1, 1);

    // Создание поля ввода (Entry)
    entry = gtk_entry_new();
    gtk_grid_attach(GTK_GRID(grid), entry, 1, 0, 1, 1);

    // Создание кнопки (Button)
    button = gtk_button_new_with_label("Обновить текст");
    gtk_grid_attach(GTK_GRID(grid), button, 0, 1, 2, 1);

    // Сохраняем указатель на label в entry (чтобы получить его в callback)
    g_object_set_data(G_OBJECT(entry), "label", label);

    // Подключаем сигнал "clicked" кнопки к функции on_button_clicked
    g_signal_connect(button, "clicked", G_CALLBACK(on_button_clicked), entry);

    // Показываем все виджеты
    gtk_widget_show_all(window);

    // Запуск главного цикла GTK
    gtk_main();

    return 0;
}