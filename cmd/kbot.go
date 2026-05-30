/*
Copyright © 2026 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/spf13/cobra"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/metric" // <--- ДОДАНО ЦЕЙ ІМПОРТ
	"gopkg.in/telebot.v4"

	"vtomchuk1/kbot/pkg/telemetry"
)

var appVersion = "0.7.0"

var (
	otelAddr     string
	serviceName  string
	otelShutdown func(context.Context) error
)

var (
	TeleToken = os.Getenv("TELE_TOKEN")
)

// kbotCmd represents the kbot command
var kbotCmd = &cobra.Command{
	Use:     "kbot",
	Aliases: []string{"go"},
	Short:   "A brief description of your command",
	Long:    `A longer description that spans multiple lines.`,

	// 1. Ініціалізуємо OpenTelemetry ПЕРЕД запуском бота
	PersistentPreRunE: func(cmd *cobra.Command, args []string) error {
		ctx, cancel := context.WithTimeout(cmd.Context(), 5*time.Second)
		defer cancel()

		shutdown, err := telemetry.InitTelemetry(ctx, serviceName, otelAddr)
		if err != nil {
			// Якщо колектор недоступний у dev-середовищі, бот все одно запуститься
			fmt.Printf("Попередження: моніторинг не ініціалізовано: %v\n", err)
			return nil
		}

		otelShutdown = shutdown
		return nil
	},

	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Kbot version:", appVersion)

		kbot, err := telebot.NewBot(telebot.Settings{
			URL:    "",
			Token:  TeleToken,
			Poller: &telebot.LongPoller{Timeout: 10 * time.Second},
		})

		if err != nil {
			log.Fatalf("Please check TELE_TOKEN env variable. %s", err)
			return
		}

		// 2. Отримуємо інструменти моніторингу з глобального реєстру
		tracer := otel.Tracer(serviceName)
		meter := otel.Meter(serviceName)

		// Створюємо метрику-лічильник для вхідних повідомлень
		msgCounter, err := meter.Int64Counter("kbot_messages_total",
			metric.WithDescription("Загальна кількість оброблених повідомлень ботом"), // <--- ВИПРАВЛЕНО НА metric.
		)
		if err != nil {
			log.Printf("Помилка створення метрики: %v", err)
		}

		// Обробник текстових повідомлень
		kbot.Handle(telebot.OnText, func(c telebot.Context) error {
			payload := c.Text()
			log.Print(payload)

			// 3. Створюємо Трейс-Спан для кожного повідомлення
			// Використовуємо cmd.Context() як базовий
			ctx, span := tracer.Start(cmd.Context(), "HandleTelegramMessage")
			defer span.End()

			// Додаємо корисні теги до спану для відображення у Grafana
			span.SetAttributes(
				attribute.String("tg.user.username", c.Sender().Username),
				attribute.Int64("tg.user.id", c.Sender().ID),
				attribute.String("tg.message.payload", payload),
			)

			// 4. Фіксуємо метрику (інкремент +1)
			if msgCounter != nil {
				msgCounter.Add(ctx, 1, metric.WithAttributes( // <--- ВИПРАВЛЕНО НА metric.
					attribute.String("command", payload),
				))
			}

			if payload == "/start" {
				err = c.Send(fmt.Sprintf("Привіт! Я Kbot - віктуальний помічник. Версія %s", appVersion))
			} else {
				err = c.Send(payload)
			}

			if err != nil {
				// Якщо сталася помилка відправки, записуємо її в трейс
				span.RecordError(err)
			}

			return err
		})

		kbot.Start()
	},

	// 5. Коректно закриваємо з'єднання після зупинки бота
	PostRun: func(cmd *cobra.Command, args []string) {
		if otelShutdown != nil {
			ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
			defer cancel()
			if err := otelShutdown(ctx); err != nil {
				log.Printf("Помилка під час зупинки OTel: %v", err)
			}
		}
	},
}

func init() {
	rootCmd.AddCommand(kbotCmd)

	// 6. Реєструємо прапори (flags) для гнучкого налаштування адреси колектора
	kbotCmd.PersistentFlags().StringVar(&otelAddr, "otel-addr", "otel-collector-opentelemetry-collector.monitoring.svc.cluster.local:4317", "Адреса OpenTelemetry Collector gRPC")
	kbotCmd.PersistentFlags().StringVar(&serviceName, "service-name", "kbot-service", "Назва сервісу для телеметрії")
}
