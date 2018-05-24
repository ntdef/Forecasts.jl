using HTTP

url = "https://raw.githubusercontent.com/jbrownlee/Datasets/master/shampoo.csv"

HTTP.get()
# load dataset
def parser(x):
	return datetime.strptime('190'+x, '%Y-%m')

series = read_csv(
    'shampoo-sales.csv',
    header=0, parse_dates=[0], index_col=0, squeeze=True, date_parser=parser)

# split data into train and test
X = series.values
train, test = X[0:-12], X[-12:]

# walk-forward validation
history = [x for x in train]
predictions = list()
for i in range(len(test)):
	# make prediction
	predictions.append(history[-1])
	# observation
	history.append(test[i])
# report performance
rmse = sqrt(mean_squared_error(test, predictions))
print('RMSE: %.3f' % rmse)
# line plot of observed vs predicted
pyplot.plot(test)
pyplot.plot(predictions)
pyplot.show()
